#!/bin/bash

# Disable job control messages
set +m

# Variables
SERVICE="_ipp._tcp.,_universal"
DOMAIN="local"
SCRIPT="airprint_bridge.sh"
LOGGING=0  # Set to 0 to disable logging
LOGFILE="airprint_bridge.log"

CMD_INSTALL=0
CMD_UNINSTALL=0
CMD_TEST=0

# Function to log messages
log() {
    if [ $LOGGING -eq 1 ]; then
        echo "$@" | tee -a "$LOGFILE" >&2
    else
        echo "$@" >&2
    fi
}

# Function to check for dependencies
check_dependencies() {
    local dependencies=("dns-sd" "lpstat" "lpoptions" "launchctl")
    for cmd in "${dependencies[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            log "Error: Required command '$cmd' is not installed."
            exit 1
        fi
    done
}

# Usage information
usage() {
    echo "Usage: $0 [options] command"
    echo ""
    echo "Command: Choose only one"
    echo "  -i, --install       Install permanently, requires sudo"
    echo "  -u, --uninstall     Uninstall, requires sudo"
    echo "  -t, --test          Test (dry run mode), use CTRL-C to exit"
    echo ""
    echo "Options:"
    echo "  -f, --script_file   Script filename and location"
    echo "  -h, --help          Print this message"
    exit 1
}

# Parse command line options
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -i|--install)
            CMD_INSTALL=1
            shift
            ;;
        -u|--uninstall)
            CMD_UNINSTALL=1
            shift
            ;;
        -t|--test)
            CMD_TEST=1
            shift
            ;;
        -f|--script_file)
            SCRIPT_FILE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Check for conflicting commands
cmd_count=$((CMD_INSTALL + CMD_UNINSTALL + CMD_TEST))
if [ $cmd_count -ne 1 ]; then
    log "Error: You must specify exactly one command."
    usage
fi

# Require sudo for install/uninstall
if [ $EUID -ne 0 ] && { [ $CMD_INSTALL -eq 1 ] || [ $CMD_UNINSTALL -eq 1 ]; }; then
    log "Error: You must run this script as root (sudo) to install or uninstall."
    exit 1
fi


# Function to check if a printer supports AirPrint
check_airprint_support() {
    local printer="$1"
    local dns_sd_output
    local dns_sd_pid
    local found=0

    dns_sd_output=$(mktemp)
    dns-sd -m -B _ipp._tcp local > "$dns_sd_output" 2>/dev/null &

    while IFS= read -r line; do
        if [[ "$line" == *"$printer"* ]]; then
            service_name=$(echo "$line" | awk '{for (i=7; i<=NF; i++) printf "%s ", $i; print ""}')
            service_name=$(echo "$service_name" | sed 's/[[:space:]]*$//')
            service_output=$(mktemp)
            dns-sd -m -L "$service_name" _ipp._tcp local > "$service_output" 2>/dev/null &

            # Check for specific AirPrint TXT records
            if grep -q "URF=" "$service_output" && grep -q "pdl=" "$service_output"; then
                found=1
                break
            fi

            rm "$service_output"
        fi
    done < "$dns_sd_output"

    rm "$dns_sd_output"

    if [ $found -eq 1 ]; then
        return 0  # Printer supports AirPrint
    else
        return 1  # Printer does not support AirPrint
    fi
}

# Function to list local shared printers without AirPrint support
browse_printers() {
    PRINTERS=()
    local all_printers
    local shared_printers=()

    log "Listing local shared printers..."

    all_printers=$(lpstat -p | awk '{print $2}')

    if [ -z "$all_printers" ]; then
        log "No printers found on this system."
        exit 1
    fi

    for printer in $all_printers; do
        if lpoptions -p "$printer" | grep -q 'printer-is-shared=true'; then
            shared_printers+=("$printer")
        fi
    done

    if [ ${#shared_printers[@]} -eq 0 ]; then
        log "No shared printers found."
        return 1
    fi

    for printer in "${shared_printers[@]}"; do
        if check_airprint_support "$printer"; then
            log "Skipping printer '$printer' as it already supports AirPrint."
        else
            PRINTERS+=("$printer")
        fi
    done

    if [ ${#PRINTERS[@]} -eq 0 ]; then
        log "No shared printers without AirPrint support found."
        return 1
    fi

    log "Found ${#PRINTERS[@]} printer(s) to process:"
    for printer in "${PRINTERS[@]}"; do
        log " - $printer"
    done
}

# Function to generate URF string based on printer capabilities
generate_urf() {
    local printer="$1"
    local urf=""

    # Retrieve printer capabilities
    local options
    options=$(lpoptions -l -p "$printer")

    # Check for supported resolutions
    if echo "$options" | grep -q "Resolution/Quality.*300dpi"; then
        urf+="RS300,"
    fi
    if echo "$options" | grep -q "Resolution/Quality.*600x600dpi"; then
        urf+="RS600,"
    fi
    if echo "$options" | grep -q "Resolution/Quality.*1200x600dpi"; then
        urf+="RS1200,"
    fi

    # Check for supported color modes
    if echo "$options" | grep -q "ColorModel/Color Mode.*Gray"; then
        urf+="W8,"
    fi
    if echo "$options" | grep -q "ColorModel/Color Mode.*RGB"; then
        urf+="SRGB24,"
    fi
    if echo "$options" | grep -q "ColorModel/Color Mode.*CMYK"; then
        urf+="ADOBERGB24,"
    fi

    # Check for duplex modes
    if echo "$options" | grep -q "Duplex/.*DuplexNoTumble"; then
        urf+="DM1,"  # Long-edge duplex
    fi
    if echo "$options" | grep -q "Duplex/.*DuplexTumble"; then
        urf+="DM3,"  # Short-edge duplex
    fi

    # Check for media types (paper types)
    if echo "$options" | grep -q "MediaType/Paper Type.*PlainPaper"; then
        urf+="MT1,"  # Plain paper
    fi
    if echo "$options" | grep -q "MediaType/Paper Type.*RECYCLED"; then
        urf+="MT2,"  # Recycled paper
    fi
    if echo "$options" | grep -q "MediaType/Paper Type.*OHP"; then
        urf+="MT3,"  # Transparency (Overhead Projector)
    fi
    if echo "$options" | grep -q "MediaType/Paper Type.*LABELS"; then
        urf+="MT4,"  # Labels
    fi
    if echo "$options" | grep -q "MediaType/Paper Type.*ENVELOPE"; then
        urf+="MT5,"  # Envelopes
    fi

    # Check for halftone and toner-saving options
    if echo "$options" | grep -q "CNHalftone/Halftones.*pattern2"; then
        urf+="CP2,"  # Halftone pattern 2
    fi
    if echo "$options" | grep -q "CNTonerSaving/Toner Save.*True"; then
        urf+="TS1,"  # Toner save mode enabled
    fi

    # Check for brightness and contrast adjustments
    if echo "$options" | grep -q "CNBrightness/Brightness.*[1-9]"; then
        urf+="BR1,"  # Brightness adjustment available
    fi
    if echo "$options" | grep -q "CNContrast/Contrast.*[1-9]"; then
        urf+="CT1,"  # Contrast adjustment available
    fi

    # Remove trailing comma
    urf=${urf%,}

    # Fallback if URF is empty
    echo "${urf:-none}"
}

# Function to resolve printer details
resolve_printer() {
    local printer_name="$1"
    TXT_RECORDS=()
    local device_uri

    log "Resolving \"$printer_name\"..."

    # Get device URI
    device_uri=$(lpstat -v "$printer_name" | awk '{print $3}' | sed 's/.$//')
    log "Device URI for $printer_name: $device_uri"

    # Determine target host and port
    if [[ "$device_uri" =~ ^ipps?:// ]]; then
        TARGET_HOST=$(echo "$device_uri" | awk -F[/:] '{print $4}')
        PORT=$(echo "$device_uri" | awk -F[/:] '{print $5}')
        PORT=${PORT:-631}
    else
        TARGET_HOST="$(hostname -s).local"
        PORT=631
    fi

    # Get printer description
    printer_desc=$(lpstat -l -p "$printer_name" | awk -F'Description:' '/Description:/ {
        gsub(/^ +| +$/, "", $2); print $2}')
    printer_desc="${printer_desc:-$printer_name @ $(hostname -s)}"
    log "Printer description for $printer_name: $printer_desc"

    # Get location
    location=$(lpstat -l -p "$printer_name" | awk -F'Location:' '/Location:/ {
        gsub(/^ +| +$/, "", $2); print $2}')
    log "Location for $printer_name: $location"

    # Get Printer Make and Model
    printer_make_and_model=$(lpoptions -p "$printer_name" | sed -n "s/.*printer-make-and-model='\([^']*\)'.*/\1/p")

    # Generate URF record
    urf=$(generate_urf "$printer_name")

    # AirPrint TXT records
    TXT_RECORDS=(
        "txtvers=1"
        "qtotal=1"
        "rp=printers/$printer_name"
        "ty=$printer_make_and_model"
        "product=($printer_make_and_model)"
        "note=${location} via $(hostname -s)"
        "pdl=application/pdf,image/jpeg,image/urf"
        "URF=$urf"
    )

    # Log final TXT records
    log "Final TXT records for $printer_name:"
    for txt_record in "${TXT_RECORDS[@]}"; do
        log "  $txt_record"
    done
}

# Function to generate the registration script
generate_script() {
    log "Generating ./$SCRIPT..."

    {
        echo "#!/bin/bash"
        echo ""
        echo "# Disable job control messages"
        echo "set +m"
        echo ""
        echo "# Trap to clean up background processes on exit"
        echo "trap 'kill \${PIDS[@]} 2>/dev/null' EXIT INT TERM"
        echo ""
        echo "PIDS=()"
        echo ""

        for printer_name in "${PRINTERS[@]}"; do
            resolve_printer "$printer_name"
            if [ $? -ne 0 ]; then
                log "Failed to resolve printer: $printer_name. Skipping..."
                continue
            fi

            # Initialize txt_record_str
            txt_record_str=""
            for txt in "${TXT_RECORDS[@]}"; do
                txt_record_str+="\"$txt\" "
            done

            # Escape the printer description for safety
            safe_printer_desc=$(printf "%s" "$printer_desc" | sed "s/'/'\\\\''/g")

            # Construct the dns-sd command with proper quoting
            cmd="dns-sd -R \"$safe_printer_desc @ $(hostname -s)\" \"$SERVICE\" \"$DOMAIN\" $PORT $txt_record_str"
           
            # Append the command and PID tracking to the generated script
            echo "$cmd &"
            echo "PIDS+=(\"\$!\")"
        done


            log "Added dns-sd command for printer: $printer_name"

            # Append the wait command to the generated script
            echo ""
            echo "# Wait for background processes"
            echo "wait"
        
            
    } > "$SCRIPT"

    chmod +x "$SCRIPT"
}


# Function to generate the plist file for launchd
generate_plist() {
    local plist_file="/Library/LaunchDaemons/com.sapireli.airprint_bridge.plist"
    local script_path="/usr/local/bin/$SCRIPT"

    log "Generating $plist_file..."

    # Ensure the script is moved to /usr/local/bin
    if [ ! -d "/usr/local/bin" ]; then
        log "Creating /usr/local/bin directory..."
        sudo mkdir -p /usr/local/bin
        sudo chown "$USER":admin /usr/local/bin
    fi

    log "Copying $SCRIPT to /usr/local/bin..."
    sudo cp "$SCRIPT" "$script_path"
    sudo chmod +x "$script_path"

    # Generate the plist file
    cat <<EOF | sudo tee "$plist_file" > /dev/null
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Label</key>
        <string>com.sapireli.airprint_bridge.plist</string>

        <key>ProgramArguments</key>
        <array>
            <string>/usr/local/bin/airprint_bridge.sh</string>
        </array>

        <key>LowPriorityIO</key>
        <true/>

        <key>Nice</key>
        <integer>1</integer>

        <key>UserName</key>
        <string>root</string>

        <key>RunAtLoad</key>
        <true/>

        <key>KeepAlive</key>
        <true/>
    </dict>
</plist>
EOF

    # Load the plist
    sudo launchctl load -w "$plist_file"
    log "Generated and loaded plist: $plist_file"
}


# Function to uninstall the script and plist
uninstall() {
    log "Uninstalling..."

    plist_file="/Library/LaunchDaemons/com.sapireli.airprint_bridge.plist"

    # Unload and remove the plist file
    if [ -f "$plist_file" ]; then
        sudo launchctl unload "$plist_file"
        sudo rm "$plist_file"
        log "Removed $plist_file"
    fi

    # Remove the script from /usr/local/bin
    if [ -f "/usr/local/bin/$SCRIPT" ]; then
        sudo rm "/usr/local/bin/$SCRIPT"
        log "Removed /usr/local/bin/$SCRIPT"
    fi

    # Kill all dns-sd processes related to the AirPrint bridge
    log "Killing dns-sd processes associated with the AirPrint bridge..."
    pgrep -f "dns-sd -R" | while read -r pid; do
        if ps -p "$pid" -o args= | grep -q "/usr/local/bin/$SCRIPT"; then
            kill "$pid" 2>/dev/null && log "Killed dns-sd process $pid" || log "Failed to kill process $pid"
        fi
    done

    log "Uninstallation complete."
}


# Function to install the script and plist
install() {
    check_dependencies
    if browse_printers; then
        generate_script
        generate_plist
        log "Installation complete."
    else
        log "Installation aborted: No suitable printers found."
    fi
}

# Function to test the script (acts as a dry run, no permanent changes made)
test() {
    check_dependencies
    if browse_printers; then
        generate_script
        log "Registering printer(s), use CTRL-C to exit"
        ./$SCRIPT
    else
        log "Test aborted: No suitable printers found."
    fi
}

# Main execution
if [ $CMD_UNINSTALL -eq 1 ]; then
    uninstall
    exit 0
fi

if [ $CMD_INSTALL -eq 1 ]; then
    install
elif [ $CMD_TEST -eq 1 ]; then
    test
else
    usage
fi
