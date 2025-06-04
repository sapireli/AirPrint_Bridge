#!/bin/bash

# AirPrint Bridge Script
# Enables AirPrint functionality for shared printers on macOS.
# Author: Eliran Sapir
# GitHub: https://github.com/sapireli/AirPrint_Bridge/
# Version: 1.3.1
# License: MIT
#
# This script is designed to make non-AirPrint printers accessible to iOS devices
# by broadcasting them as AirPrint-compatible using macOS's built-in tools.
#
# For more details, documentation, or to contribute, visit the GitHub repository.

# ------------------------------START------------------------------

# Disable job control messages
set +m

# Forcing an English locale inside the script:
export SOFTWARE=
export LANG=C
export LC_ALL=C

# Variables
SERVICE="_ipp._tcp.,_universal"
DOMAIN="local"
SCRIPT="airprint_bridge_launcher.sh"
LOGGING=0  # Set to 0 to disable logging
LOGFILE="airprint_bridge.log"
SCRIPT_FILE=""
CUPS_CONF_CHANGED=0

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

# Check & Fix Firewall
check_firewall() {
  log "Checking macOS firewall..."
  local fw_state
  fw_state=$(sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null)
  if echo "$fw_state" | grep -qi "enabled"; then
    log "Firewall is enabled. Ensuring CUPS is allowed..."
    local cups_bin
    cups_bin=$(which cupsd 2>/dev/null || echo "/usr/sbin/cupsd")
    if ! sudo /usr/libexec/ApplicationFirewall/socketfilterfw --listapps | grep -q "$cups_bin"; then
      sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add "$cups_bin"
      sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp "$cups_bin"
      log "Allowed $cups_bin in firewall."
    fi
  else
    log "Firewall is disabled; skipping."
  fi
}

# Check & Fix CUPS Permissions
check_cups_permissions() {
  log "Checking CUPS permissions..."
  local cupsd_conf="/etc/cups/cupsd.conf"

  # 1) Global remote access
  if ! grep -q "Allow @LOCAL" "$cupsd_conf" 2>/dev/null; then
    log "CUPS does not allow remote access to shared printers. Backing up cups config to cupsd_conf.bak, and auto fixing"

      [ ! -f "${cupsd_conf}.bak" ] && sudo cp "$cupsd_conf" "${cupsd_conf}.bak"
      sudo sed -i '' '/<Location \/>/,/<\/Location>/ s/Order allow,deny/Order allow,deny\n  Allow @LOCAL/' "$cupsd_conf"
      if sudo cupsd -t; then
        sudo launchctl stop org.cups.cupsd
        sudo launchctl start org.cups.cupsd
        CUPS_CONF_CHANGED=1
        log "Autofix successful: enabled remote access in CUPS."
      else
        log "CUPS config invalid. Restoring backup..."
        revert_cups_config
        exit 1
      fi
  else
    log "CUPS remote access is already allowed."
  fi

  # 2) Shared printers must allow all users
  local allp
  allp=$(lpstat -p | awk '{print $2}')
  while IFS= read -r p; do
    if lpoptions -p "$p" | grep -q "printer-is-shared=true"; then
      if ! lpstat -l -p "$p" | grep -iq "allowed users: all"; then
        log "Printer '$p' is shared but does not allow all users. Autofixing"
        sudo lpadmin -p "$p" -u allow:all
        log "Printer '$p' now allows all users."
      fi
    fi
  done <<< "$allp"
}

# Revert CUPS config if it was changed and a backup exists
revert_cups_config() {
  local cupsd_conf="/etc/cups/cupsd.conf"
  if [ "$CUPS_CONF_CHANGED" -eq 1 ] && [ -f "${cupsd_conf}.bak" ]; then
    log "Reverting changes to $cupsd_conf..."
    sudo cp "${cupsd_conf}.bak" "$cupsd_conf"
    sudo launchctl stop org.cups.cupsd
    sudo launchctl start org.cups.cupsd
    log "CUPS configuration restored."
  fi
}

# Usage information
usage() {
    echo "Usage: $0 [-i | -u | -t] [-f script_file] [-h]"
    echo "  -i  Install (requires sudo)"
    echo "  -u  Uninstall (requires sudo)"
    echo "  -t  Test (dry run mode), use CTRL-C to exit"
    echo "  -f  Script filename and location"
    echo "  -h  Print this message"
    exit 1
}

COMMAND=""

# Parse command line options using getopts (simplified approach)
while getopts ":iutf:h" opt; do
    case "$opt" in
        i) COMMAND="install" ;;
        u) COMMAND="uninstall" ;;
        t) COMMAND="test" ;;
        f) SCRIPT_FILE="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

shift $((OPTIND -1))

# Ensure exactly one main command was chosen
if [ -z "$COMMAND" ]; then
    log "Error: You must specify exactly one command."
    usage
fi

# Require sudo for install/uninstall/test
if [ "$EUID" -ne 0 ] && { [ "$COMMAND" = "install" ] || [ "$COMMAND" = "uninstall" ] || [ "$COMMAND" = "test" ]; }; then
    log "Error: You must run this script as root (sudo) to install, uninstall, or test."
    exit 1
fi


# Function to list local shared printers without AirPrint support
# Finds printers on the system that are shared but do not currently support AirPrint.
browse_printers() {
    PRINTERS=()
    log "Listing local shared printers..."
    all_printers=$(lpstat -p | awk '{print $2}')

    if [ -z "$all_printers" ]; then
        log "No printers found on this system."
        return 1
    fi

    shared_printers=()
    while IFS= read -r printer; do
        if lpoptions -p "$printer" | grep -q 'printer-is-shared=true'; then
            shared_printers+=("$printer")
        fi
    done <<< "$all_printers"

    if [ ${#shared_printers[@]} -eq 0 ]; then
        log "No shared printers found."
        return 1
    fi

    for printer in "${shared_printers[@]}"; do
        PRINTERS+=("$printer")
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
# This inspects printer options (color mode, media, etc.) and builds a URF record.
generate_urf() {
    local printer="$1"
    local urf=""
    local urf_version="V1.4"

    # Function to add URF code if not already present
    add_urf_code() {
        local code="$1"
        [[ "$urf" != *"$code,"* ]] && urf+="$code,"
    }

    # Validate printer name
    if [[ -z "$printer" ]]; then
        log "No printer specified."
        return 1
    fi

    # Check if the printer exists
    if ! lpstat -p "$printer" >/dev/null 2>&1; then
        log "Printer '$printer' does not exist"
        return 1
    fi

    # Retrieve printer capabilities
    options=$(lpoptions -l -p "$printer" 2>/dev/null) || { log "Unable to get options for '$printer'."; return 1; }

    # Parse each line of the lpoptions output
    # Update URF codes based on supported print qualities, media types, etc.
    while IFS= read -r line; do
        case "$line" in
            # Color Mode Options
            *"ColorModel"*)
                IFS=' ' read -r -a color_modes <<< "$(echo "$line" | awk -F': ' '{print $2}')"
                for color_mode in "${color_modes[@]}"; do
                    case "$color_mode" in
                        *Gray*|*Black*) add_urf_code "W8" ;;
                        *RGB*|*Color*) add_urf_code "SRGB24" ;;
                        *AdobeRGB*) add_urf_code "ADOBERGB24" ;;
                        *CMYK*) add_urf_code "CMYK32" ;;
                    esac
                done
                ;;
            
            # Print Quality Options
            *"cupsPrintQuality/Quality:"*)
                IFS=' ' read -r -a qualities <<< "$(echo "$line" | awk -F': ' '{print $2}')"
                for quality in "${qualities[@]}"; do
                    case "$quality" in
                        *Draft*) add_urf_code "PQ1" ;;
                        *Normal*) add_urf_code "PQ2" ;;
                        *High*) add_urf_code "PQ3" ;;
                        *Photo*|*Best*) add_urf_code "PQ4" ;;
                    esac
                done
                ;;

            # Orientation Options
            *"Orientation"*|*"orientation"*)
                IFS=' ' read -r -a orientations <<< "$(echo "$line" | awk -F': ' '{print $2}')"
                for orient in "${orientations[@]}"; do
                    case "$orient" in
                        *Portrait*|*None*) add_urf_code "OR0" ;;
                        *Landscape*) add_urf_code "OR1" ;;
                        *ReverseLandscape*) add_urf_code "OR2" ;;
                        *ReversePortrait*) add_urf_code "OR3" ;;
                    esac
                done
                ;;

           
            # Duplex Mode Options
            *"Duplex"*)
                IFS=' ' read -r -a duplex_modes <<< "$(echo "$line" | awk -F': ' '{print $2}')"
                for duplex_mode in "${duplex_modes[@]}"; do
                    case "$duplex_mode" in
                        *None*|*Off*|*Simplex*) add_urf_code "DM1" ;;
                        *DuplexNoTumble*) add_urf_code "DM2" ;;
                        *DuplexTumble*) add_urf_code "DM3" ;;
                        *DuplexManual*) add_urf_code "DM4" ;;
                    esac
                done
                ;;
            
            # Media Size Options
            *"PageSize/Media Size:"*)
                IFS=' ' read -r -a media_sizes <<< "$(echo "$line" | awk -F': ' '{print $2}')"
                for media_size in "${media_sizes[@]}"; do
                    case "$media_size" in
                        *Letter*) add_urf_code "MS_LETTER" ;;
                        *Legal*) add_urf_code "MS_LEGAL" ;;
                        *A4*) add_urf_code "MS_A4" ;;
                        *A3*) add_urf_code "MS_A3" ;;
                        *A5*) add_urf_code "MS_A5" ;;
                        *A6*) add_urf_code "MS_A6" ;;
                        *B5*) add_urf_code "MS_B5" ;;
                        *Executive*) add_urf_code "MS_EXECUTIVE" ;;
                        *Tabloid*) add_urf_code "MS_TABLOID" ;;
                        *4x6*|*4X6*) add_urf_code "MS_4X6" ;;
                        *5x7*|*5X7*) add_urf_code "MS_5X7" ;;
                    esac
                done
                ;;
            
            # Media Type Options
            *"MediaType/MediaType:"*)
                IFS=' ' read -r -a media_types <<< "$(echo "$line" | awk -F': ' '{print $2}')"
                for media_type in "${media_types[@]}"; do
                    case "$media_type" in
                        *stationery*|*any*) add_urf_code "MT0" ;;
                        *plain*) add_urf_code "MT1" ;;
                        *recycled*) add_urf_code "MT2" ;;
                        *transparency*) add_urf_code "MT3" ;;
                        *labels*) add_urf_code "MT4" ;;
                        *envelope*) add_urf_code "MT5" ;;
                        *photographic*) add_urf_code "MT6" ;;
                        *glossy*) add_urf_code "MT7" ;;
                        *matte*) add_urf_code "MT8" ;;
                        *cardstock*) add_urf_code "MT9" ;;
                        *letterhead*) add_urf_code "MT10" ;;
                    esac
                done
                ;;
            
            # Input Slot (Media Source) Options
            *"InputSlot/Media Source:"*)
                IFS=' ' read -r -a input_slots <<< "$(echo "$line" | awk -F': ' '{print $2}')"
                for input_slot in "${input_slots[@]}"; do
                    case "$input_slot" in
                        *auto*) add_urf_code "IS1" ;;
                        *tray-1*) add_urf_code "IS2" ;;
                        *tray-2*) add_urf_code "IS3" ;;
                        *Manual*) add_urf_code "IS4" ;;
                        *tray-3*) add_urf_code "IS5" ;;
                        *tray-4*) add_urf_code "IS6" ;;
                        *tray-5*) add_urf_code "IS7" ;;
                        *envelope*) add_urf_code "IS8" ;;
                        *multi*|*multipurpose*) add_urf_code "IS9" ;;
                        *photo*) add_urf_code "IS10" ;;
                    esac
                done
                ;;
        esac
    done <<< "$options"

    # Remove trailing comma from URF string
    urf=${urf%,}

    # Add URF version if URF codes are present
    if [[ -n "$urf" ]]; then
        urf="$urf_version,$urf"
    fi

    # Output the final URF string or 'none' if empty
    echo "${urf:-none}"
}

# Function to resolve printer details
# Identifies printer URI, host, port, description, location, and constructs AirPrint TXT records.
resolve_printer() {
    local printer_name="$1"
    TXT_RECORDS=()

    log "Resolving \"$printer_name\"..."

    # Get device URI
    device_uri=$(lpstat -v "$printer_name" | awk '{print $3}' | sed 's/.$//')
    log "Device URI: $device_uri"

    # Determine target host and port
    if [[ "$device_uri" =~ ^ipps?:// ]]; then
        PORT=$(echo "$device_uri" | awk -F[/:] '{print $5}')
        PORT=${PORT:-631}
    else
        PORT=631
    fi

    # Get printer description
    printer_desc=$(lpstat -l -p "$printer_name" | awk -F'Description:' '/Description:/ {gsub(/^ +| +$/,"",$2); print $2}')
    printer_desc="${printer_desc:-$printer_name @ $(hostname -s)}"
    log "Description: $printer_desc"

    # Get location
    location=$(lpstat -l -p "$printer_name" | awk -F'Location:' '/Location:/ {gsub(/^ +| +$/,"",$2); print $2}')
    log "Location: $location"

    # Get Printer Make and Model
    printer_make_and_model=$(lpoptions -p "$printer_name" | sed -En "s/.*printer-make-and-model=('([^']*)'|([^=]*)) .*/\2\3/p")

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

    log "TXT records:"
    for txt_record in "${TXT_RECORDS[@]}"; do
        log "  $txt_record"
    done
}

# Function to generate the registration script
# Creates a script that runs dns-sd registration commands for each printer.
generate_script() {
    log "Generating ./$SCRIPT..."
    {
        echo "#!/bin/bash"
        echo "set +m"
        echo "trap 'kill \${PIDS[@]} 2>/dev/null' EXIT INT TERM"
        echo "PIDS=()"
        for printer_name in "${PRINTERS[@]}"; do
            if ! resolve_printer "$printer_name"; then
                log "Failed to resolve: $printer_name"
                continue
            fi
            txt_record_str=""
            for txt in "${TXT_RECORDS[@]}"; do
                txt_record_str+="\"$txt\" "
            done
            safe_printer_desc=$(printf "%s" "$printer_desc" | sed "s/'/'\\\\''/g")
            cmd="dns-sd -R \"$safe_printer_desc @ $(hostname -s)\" \"$SERVICE\" \"$DOMAIN\" $PORT $txt_record_str"
            echo "$cmd &"
            echo "PIDS+=(\"\$!\")"
        done
        echo "wait"
    } > "$SCRIPT"
    chmod +x "$SCRIPT"
}

# Function to generate the plist file for launchd
# Creates a LaunchDaemon plist to run the script at system startup and keep it alive.
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
            <string>$script_path</string>
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
    log "Plist loaded: $plist_file"
}

# Function to uninstall the script and plist
# Removes LaunchDaemon and the script, and kills any related dns-sd processes.
uninstall() {
    log "Uninstalling..."
    plist_file="/Library/LaunchDaemons/com.sapireli.airprint_bridge.plist"
    
    revert_cups_config

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
            if kill "$pid" 2>/dev/null; then
                log "Killed dns-sd process $pid"
            else
                log "Failed to kill process $pid"
            fi
        fi
    done

    log "Uninstallation complete."
}

# Function to install the script and plist
# Checks dependencies, finds printers, generates scripts, and installs LaunchDaemon.
install() {
    check_dependencies
    check_cups_permissions
    check_firewall
    if browse_printers; then
        generate_script
        generate_plist
        log "Installation complete."
    else
        log "Installation aborted: No suitable printers found."
    fi
}

# Function to test the script (acts as a dry run, no permanent changes made)
# Registers printers temporarily; use CTRL-C to exit.
test_run() {
    check_dependencies
    check_cups_permissions
    check_firewall
    
    if browse_printers; then
        generate_script
        log "Registering printer(s), use CTRL-C to exit"
        ./$SCRIPT
    else
        log "Test aborted: No suitable printers found."
    fi
}

# Main execution based on COMMAND
case "$COMMAND" in
    install) install ;;
    uninstall) uninstall ;;
    test) test_run ;;
esac
