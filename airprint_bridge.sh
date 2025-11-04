#!/bin/bash

# AirPrint Bridge Script
# Enables AirPrint functionality for shared printers on macOS.
# Author: Eliran Sapir
# GitHub: https://github.com/sapireli/AirPrint_Bridge/
# Version: 1.3.2
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
HAS_COLOR=0
HAS_DUPLEX=0
URF=""
ADVERTISED_NAME=""

# Helper to percent-encode strings for resource paths
percent_encode() {
    local input="$1"
    local output=""
    local i char hex

    for ((i = 0; i < ${#input}; i++)); do
        char=${input:i:1}
        case "$char" in
            [a-zA-Z0-9._~-])
                output+="$char"
                ;;
            *)
                local decimal
                decimal=$(printf '%s' "$char" | LC_ALL=C od -An -t u1)
                decimal=${decimal//[[:space:]]/}
                printf -v hex '%02X' "$decimal"
                output+="%$hex"
                ;;
        esac
    done

    printf '%s\n' "$output"
}

# Helper to shell-escape arguments when emitting scripts
shell_escape() {
    local value="$1"
    printf '%q\n' "$value"
}

# Remove control characters and trim whitespace for TXT fields
sanitize_txt_value() {
    local value="$1"

    value=${value//$'\r'/$' '}
    value=${value//$'\n'/$' '}
    value=${value//$'\t'/$' '}
    value=$(printf '%s' "$value" | LC_ALL=C sed $'s/[\001-\037\177]/ /g')
    value=$(printf '%s' "$value" | sed 's/[[:space:]]\+/ /g; s/^ //; s/ $//')

    printf '%s\n' "$value"
}

# Parse device URIs and emit HOST/PORT assignments
parse_device_uri() {
    local uri="$1"
    local scheme=""
    local remainder="$uri"
    local host_port=""
    local host=""
    local port=""

    if [[ "$remainder" == *"://"* ]]; then
        scheme=${remainder%%://*}
        remainder=${remainder#*://}
    fi

    host_port=${remainder%%/*}

    if [[ "$host_port" == \[*\]* ]]; then
        host=${host_port%%]*}
        host=${host#[}
        local after_bracket=${host_port#*]}
        if [[ "$after_bracket" == :* ]]; then
            port=${after_bracket#:}
        fi
    else
        if [[ "$host_port" == *:* ]]; then
            host=${host_port%%:*}
            port=${host_port##*:}
        else
            host=$host_port
        fi
    fi

    case "$scheme" in
        ipp|ipps)
            [[ -z "$port" ]] && port=631
            ;;
        http)
            [[ -z "$port" ]] && port=80
            ;;
        https)
            [[ -z "$port" ]] && port=443
            ;;
        socket)
            [[ -z "$port" ]] && port=9100
            ;;
        lpd)
            [[ -z "$port" ]] && port=515
            ;;
    esac

    [[ -z "$port" ]] && port=0

    printf 'HOST=%s\n' "$host"
    printf 'PORT=%s\n' "$port"
}

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
    HAS_COLOR=0
    HAS_DUPLEX=0
    URF=""

    if [[ -z "$printer" ]]; then
        log "No printer specified."
        return 1
    fi

    if ! lpstat -p "$printer" >/dev/null 2>&1; then
        log "Printer '$printer' does not exist"
        return 1
    fi

    local lpoptions_output
    if ! lpoptions_output=$(lpoptions -l -p "$printer" 2>/dev/null); then
        log "Unable to query options for '$printer'"
        return 1
    fi

    local parsed_choices=""
    while IFS= read -r line; do
        [[ "$line" == *:* ]] || continue
        local option="${line%%:*}"
        option="${option%%/*}"
        local rest="${line#*:}"
        read -r -a tokens <<< "$rest"
        local token
        for token in "${tokens[@]}"; do
            token=${token#\*}
            [[ "$token" == */* ]] || continue
            local canonical="${token%%/*}"
            [[ -z "$canonical" ]] && continue
            parsed_choices+="$option:$canonical"$'\n'
        done
    done <<< "$lpoptions_output"

    local codes=()
    add_code() {
        local code="$1"
        local existing
        [[ -z "$code" ]] && return
        for existing in "${codes[@]}"; do
            [[ "$existing" == "$code" ]] && return
        done
        codes+=("$code")
    }

    local has_color=0
    local has_duplex=0

    while IFS=':' read -r option canonical; do
        [[ -z "$option" || -z "$canonical" ]] && continue
        local option_lower
        option_lower=$(printf '%s' "$option" | tr '[:upper:]' '[:lower:]')
        local lower_choice
        lower_choice=$(printf '%s' "$canonical" | tr '[:upper:]' '[:lower:]')

        case "$option_lower" in
            colormodel|outputmode|colormode|color)
                if [[ "$lower_choice" == "k" || "$lower_choice" == "mono" || "$lower_choice" == "monochrome" ||
                      "$lower_choice" == "gray" || "$lower_choice" == "grey" || "$lower_choice" == "black" ||
                      "$lower_choice" == *"gray"* || "$lower_choice" == *"grey"* || "$lower_choice" == *"mono"* ||
                      "$lower_choice" == *"black"* ]]; then
                    add_code "W8"
                fi
                if [[ "$lower_choice" == *"adobe"* ]]; then
                    add_code "ADOBERGB24"
                    has_color=1
                fi
                if [[ "$lower_choice" == *"srgb"* || "$lower_choice" == *"rgb"* || "$lower_choice" == *"color"* ]]; then
                    add_code "SRGB24"
                    has_color=1
                fi
                if [[ "$lower_choice" == *"cmyk"* ]]; then
                    add_code "CMYK32"
                    has_color=1
                fi
                ;;
            cupsprintquality|printquality|quality)
                if [[ "$lower_choice" == *"draft"* || "$lower_choice" == *"fast"* ]]; then
                    add_code "PQ1"
                elif [[ "$lower_choice" == *"normal"* || "$lower_choice" == *"standard"* ]]; then
                    add_code "PQ2"
                elif [[ "$lower_choice" == *"high"* ]]; then
                    add_code "PQ3"
                elif [[ "$lower_choice" == *"best"* || "$lower_choice" == *"photo"* ]]; then
                    add_code "PQ4"
                fi
                ;;
            orientation|orientation-requested)
                if [[ "$lower_choice" == *"portrait"* || "$lower_choice" == "none" || "$lower_choice" == "3" ]]; then
                    add_code "OR0"
                fi
                if [[ "$lower_choice" == *"landscape"* && "$lower_choice" != *"reverse"* ]] || [[ "$lower_choice" == "4" ]]; then
                    add_code "OR1"
                fi
                if [[ "$lower_choice" == *"reverse"* && "$lower_choice" == *"landscape"* ]] || [[ "$lower_choice" == "5" ]]; then
                    add_code "OR2"
                fi
                if [[ "$lower_choice" == *"reverse"* && "$lower_choice" == *"portrait"* ]] || [[ "$lower_choice" == "6" ]]; then
                    add_code "OR3"
                fi
                ;;
            duplex|duplexer|efduplex)
                if [[ "$lower_choice" == *"simplex"* || "$lower_choice" == "none" || "$lower_choice" == *"off"* ]]; then
                    add_code "DM1"
                fi
                if [[ "$lower_choice" == *"notumble"* || "$lower_choice" == *"long"* ]]; then
                    add_code "DM2"
                    has_duplex=1
                fi
                if [[ "$lower_choice" == *"tumble"* || "$lower_choice" == *"short"* ]]; then
                    add_code "DM3"
                    has_duplex=1
                fi
                if [[ "$lower_choice" == *"manual"* ]]; then
                    add_code "DM4"
                    has_duplex=1
                fi
                ;;
            pagesize|pageregion|papersize)
                case "$lower_choice" in
                    *"letter"*|*"8.5x11"*) add_code "MS_LETTER" ;;
                    *"legal"*|*"8.5x14"*) add_code "MS_LEGAL" ;;
                    *"a4"*) add_code "MS_A4" ;;
                    *"a3"*) add_code "MS_A3" ;;
                    *"a5"*) add_code "MS_A5" ;;
                    *"a6"*) add_code "MS_A6" ;;
                    *"b5"*) add_code "MS_B5" ;;
                    *"executive"*) add_code "MS_EXECUTIVE" ;;
                    *"tabloid"*) add_code "MS_TABLOID" ;;
                    *"4x6"*|*"10x15"*) add_code "MS_4X6" ;;
                    *"5x7"*) add_code "MS_5X7" ;;
                esac
                ;;
            mediatype|hpmediatype|papertype)
                case "$lower_choice" in
                    *"stationery"*|*"any"*) add_code "MT0" ;;
                    *"plain"*) add_code "MT1" ;;
                    *"recycled"*) add_code "MT2" ;;
                    *"transparency"*) add_code "MT3" ;;
                    *"label"*) add_code "MT4" ;;
                    *"envelope"*) add_code "MT5" ;;
                    *"photo"*) add_code "MT6" ;;
                    *"gloss"*) add_code "MT7" ;;
                    *"matte"*) add_code "MT8" ;;
                    *"card"*) add_code "MT9" ;;
                    *"letterhead"*) add_code "MT10" ;;
                esac
                ;;
            inputslot|mediasource|tray)
                case "$lower_choice" in
                    auto|autoselect|automatic|default) add_code "IS1" ;;
                    tray-1|tray1|upper|main|source-1|first|tray_1) add_code "IS2" ;;
                    tray-2|tray2|lower|source-2|second|tray_2) add_code "IS3" ;;
                    manual|manualfeed|bypassmanual) add_code "IS4" ;;
                    tray-3|tray3|middle|source-3|third|tray_3) add_code "IS5" ;;
                    tray-4|tray4|source-4|fourth|tray_4) add_code "IS6" ;;
                    tray-5|tray5|source-5|fifth|tray_5) add_code "IS7" ;;
                    envelope*) add_code "IS8" ;;
                    bypass|multipurpose|mp|mptray|multi-purpose|auxiliary) add_code "IS9" ;;
                    photo|phototray|tray-photo) add_code "IS10" ;;
                esac
                ;;
        esac
    done <<< "$parsed_choices"

    if [[ $has_duplex -eq 1 ]]; then
        local found_dm1=0
        local code
        for code in "${codes[@]}"; do
            if [[ "$code" == "DM1" ]]; then
                found_dm1=1
                break
            fi
        done
        if [[ $found_dm1 -eq 0 ]]; then
            add_code "DM1"
        fi
    fi

    if [[ ${#codes[@]} -gt 0 ]]; then
        local saved_ifs="$IFS"
        IFS=','
        local joined="${codes[*]}"
        IFS="$saved_ifs"
        URF="V1.4,$joined"
    else
        URF="V1.4"
    fi

    HAS_COLOR=$has_color
    HAS_DUPLEX=$has_duplex
}

# Function to resolve printer details
# Identifies printer URI, host, port, description, location, and constructs AirPrint TXT records.
resolve_printer() {
    local printer_name="$1"
    TXT_RECORDS=()

    log "Resolving \"$printer_name\"..."

    # Get device URI
    device_uri=$(lpstat -v "$printer_name" 2>/dev/null | awk -F': ' 'NR==1 {print $2}')
    device_uri=$(sanitize_txt_value "$device_uri")
    log "Device URI: $device_uri"

    # Determine target host and port
    TARGET_HOST=""
    PORT=""
    if [[ -n "$device_uri" ]]; then
        local uri_components
        uri_components=$(parse_device_uri "$device_uri")
        while IFS='=' read -r key value; do
            case "$key" in
                HOST) TARGET_HOST="$value" ;;
                PORT) PORT="$value" ;;
            esac
        done <<< "$uri_components"
    fi

    if [[ -z "$PORT" || "$PORT" == "0" ]]; then
        PORT=631
    fi
    if [[ -n "$TARGET_HOST" ]]; then
        TARGET_HOST=$(sanitize_txt_value "$TARGET_HOST")
    fi
    if [[ -n "$TARGET_HOST" ]]; then
        log "Target host: $TARGET_HOST"
    fi
    log "Port: $PORT"

    # Get printer description
    local raw_desc
    raw_desc=$(lpstat -l -p "$printer_name" | awk -F'Description:' '/Description:/ {gsub(/^ +| +$/,"",$2); print $2; exit}')
    if [[ -z "$raw_desc" ]]; then
        raw_desc="$printer_name"
    fi
    printer_desc=$(sanitize_txt_value "$raw_desc")
    local host_short
    host_short=$(sanitize_txt_value "$(hostname -s)")
    ADVERTISED_NAME=$(sanitize_txt_value "$printer_desc @ $host_short")
    if [[ -z "$ADVERTISED_NAME" ]]; then
        ADVERTISED_NAME=$(sanitize_txt_value "$printer_name @ $host_short")
    fi
    log "Description: $printer_desc"

    # Get location
    local raw_location
    raw_location=$(lpstat -l -p "$printer_name" | awk -F'Location:' '/Location:/ {gsub(/^ +| +$/,"",$2); print $2; exit}')
    location=$(sanitize_txt_value "$raw_location")
    log "Location: $location"

    # Get Printer Make and Model
    printer_make_and_model=$(lpoptions -p "$printer_name" | sed -En "s/.*printer-make-and-model=('([^']*)'|([^=]*)) .*/\2\3/p")
    printer_make_and_model=$(sanitize_txt_value "$printer_make_and_model")

    # Generate URF record and capability flags
    generate_urf "$printer_name" || { log "Failed to generate URF for $printer_name"; return 1; }
    urf="$URF"
    local color_flag
    local duplex_flag
    if [ "$HAS_COLOR" -eq 1 ]; then
        color_flag="T"
    else
        color_flag="F"
    fi
    if [ "$HAS_DUPLEX" -eq 1 ]; then
        duplex_flag="T"
    else
        duplex_flag="F"
    fi

    # AirPrint TXT records
    local encoded_resource_path
    encoded_resource_path=$(percent_encode "$printer_name")
    local ty_value
    ty_value=${printer_make_and_model:-$printer_desc}
    ty_value=$(sanitize_txt_value "$ty_value")
    local product_value
    product_value="(${ty_value})"
    product_value=$(sanitize_txt_value "$product_value")
    local note_value
    if [[ -n "$location" ]]; then
        note_value="$location via $host_short"
    else
        note_value="Shared via $host_short"
    fi
    note_value=$(sanitize_txt_value "$note_value")

    TXT_RECORDS=(
        "txtvers=1"
        "qtotal=1"
        "rp=printers/$encoded_resource_path"
        "ty=$ty_value"
        "product=$product_value"
        "note=$note_value"
        "pdl=application/pdf,image/jpeg,image/urf"
        "URF=$urf"
        "Color=$color_flag"
        "Duplex=$duplex_flag"
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
                txt_record_str+=" $(shell_escape "$txt")"
            done
            local escaped_name
            escaped_name=$(shell_escape "$ADVERTISED_NAME")
            local escaped_service
            escaped_service=$(shell_escape "$SERVICE")
            local escaped_domain
            escaped_domain=$(shell_escape "$DOMAIN")
            cmd="dns-sd -R $escaped_name $escaped_service $escaped_domain $PORT$txt_record_str"
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

    # Kill dns-sd processes advertising AirPrint services
    log "Killing dns-sd processes advertising $SERVICE..."
    pids=$(pgrep -f "dns-sd -R")
    if [ -z "$pids" ]; then
        log "No dns-sd processes found"
    else
        for pid in $pids; do
            if ps -p "$pid" -o args= | grep -q "$SERVICE"; then
                if kill "$pid" 2>/dev/null; then
                    log "Killed dns-sd process $pid"
                else
                    log "Failed to kill process $pid"
                fi
            fi
        done
    fi

    # Wait briefly to ensure Bonjour ads are removed
    sleep 2

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
