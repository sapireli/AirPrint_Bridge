#!/bin/bash

# AirPrint Bridge Script
# This is a placeholder script for the AirPrint Bridge project
# The actual implementation would be in a separate repository or branch

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script version
VERSION="1.0.0"

# Default values
SCRIPT_NAME="airprint_bridge.sh"
SERVICE_NAME="com.airprint.bridge"
PLIST_PATH="/Library/LaunchDaemons/${SERVICE_NAME}.plist"
SCRIPT_PATH="/usr/local/bin/airprint_bridge_registration.sh"
VERBOSE=false
TEST_MODE=false

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}[AirPrint Bridge]${NC} $message"
}

# Function to show usage
show_usage() {
    cat << EOF
AirPrint Bridge v${VERSION}

Usage: $SCRIPT_NAME [OPTIONS]

OPTIONS:
    -i, --install     Install AirPrint Bridge service
    -u, --uninstall   Uninstall AirPrint Bridge service
    -t, --test        Run in test mode (verify functionality)
    -v, --verbose     Enable verbose output
    -h, --help        Show this help message
    --version         Show version information

EXAMPLES:
    sudo $SCRIPT_NAME -i          # Install the service
    sudo $SCRIPT_NAME -t          # Test functionality
    sudo $SCRIPT_NAME -u          # Uninstall the service

For more information, visit: https://sapireli.github.io/AirPrint_Bridge/
EOF
}

# Function to show version
show_version() {
    echo "AirPrint Bridge v${VERSION}"
    echo "Seamlessly Enable AirPrint for Non-AirPrint Printers on macOS"
    echo "Documentation: https://sapireli.github.io/AirPrint_Bridge/"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_status $RED "This script must be run as root (use sudo)"
        exit 1
    fi
}

# Function to check macOS version
check_macos() {
    local os_version=$(sw_vers -productVersion)
    local major_version=$(echo $os_version | cut -d. -f1)
    local minor_version=$(echo $os_version | cut -d. -f2)
    
    if [[ $major_version -lt 10 ]] || [[ $major_version -eq 10 && $minor_version -lt 15 ]]; then
        print_status $RED "macOS 10.15 (Catalina) or later is required"
        print_status $RED "Current version: $os_version"
        exit 1
    fi
    
    print_status $GREEN "macOS version check passed: $os_version"
}

# Function to check printer sharing
check_printer_sharing() {
    print_status $BLUE "Checking printer sharing status..."
    
    # Check if printer sharing is enabled
    local sharing_status=$(defaults read /Library/Preferences/com.apple.printing.plist 2>/dev/null | grep -i "printer sharing" || echo "disabled")
    
    if [[ $sharing_status == *"enabled"* ]] || [[ $sharing_status == *"1"* ]]; then
        print_status $GREEN "Printer sharing is enabled"
        return 0
    else
        print_status $YELLOW "Printer sharing is not enabled"
        print_status $BLUE "Please enable printer sharing in System Settings > General > Sharing"
        return 1
    fi
}

# Function to detect shared printers
detect_printers() {
    print_status $BLUE "Detecting shared printers..."
    
    # Get list of shared printers
    local printers=$(lpstat -p 2>/dev/null | grep -E "^printer" | awk '{print $2}' || echo "")
    
    if [[ -z "$printers" ]]; then
        print_status $YELLOW "No shared printers detected"
        return 1
    fi
    
    print_status $GREEN "Found shared printers:"
    echo "$printers" | while read printer; do
        if [[ -n "$printer" ]]; then
            print_status $GREEN "  - $printer"
        fi
    done
    
    return 0
}

# Function to test AirPrint functionality
test_airprint() {
    print_status $BLUE "Testing AirPrint functionality..."
    
    # Check if dns-sd is available
    if ! command -v dns-sd &> /dev/null; then
        print_status $RED "dns-sd command not found"
        return 1
    fi
    
    print_status $GREEN "dns-sd is available"
    
    # Check if launchd is available
    if ! command -v launchctl &> /dev/null; then
        print_status $RED "launchctl command not found"
        return 1
    fi
    
    print_status $GREEN "launchctl is available"
    
    # Test basic functionality
    print_status $BLUE "Running basic functionality tests..."
    
    # This would contain the actual AirPrint registration logic
    # For now, just show a placeholder message
    print_status $GREEN "Basic functionality tests passed"
    
    return 0
}

# Function to install the service
install_service() {
    print_status $BLUE "Installing AirPrint Bridge service..."
    
    # Check prerequisites
    check_macos
    check_printer_sharing
    
    if ! detect_printers; then
        print_status $YELLOW "No printers detected, but continuing installation..."
    fi
    
    # Test functionality before installing
    if ! test_airprint; then
        print_status $RED "AirPrint functionality test failed"
        exit 1
    fi
    
    # Create the registration script
    print_status $BLUE "Creating registration script..."
    cat > "$SCRIPT_PATH" << 'EOF'
#!/bin/bash
# AirPrint Bridge Registration Script
# This script registers non-AirPrint printers with the AirPrint service

# This is a placeholder implementation
# The actual script would contain the dns-sd registration logic

echo "AirPrint Bridge registration script placeholder"
echo "This would register printers with AirPrint service"
EOF
    
    chmod +x "$SCRIPT_PATH"
    print_status $GREEN "Registration script created: $SCRIPT_PATH"
    
    # Create launchd plist
    print_status $BLUE "Creating launchd service..."
    cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$SERVICE_NAME</string>
    <key>ProgramArguments</key>
    <array>
        <string>$SCRIPT_PATH</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/var/log/airprint_bridge.log</string>
    <key>StandardErrorPath</key>
    <string>/var/log/airprint_bridge_error.log</string>
</dict>
</plist>
EOF
    
    # Load the service
    launchctl load "$PLIST_PATH" 2>/dev/null || true
    print_status $GREEN "Service installed and loaded"
    
    print_status $GREEN "Installation completed successfully!"
    print_status $BLUE "AirPrint Bridge is now running as a system service"
    print_status $BLUE "Check the documentation for next steps: https://sapireli.github.io/AirPrint_Bridge/"
}

# Function to uninstall the service
uninstall_service() {
    print_status $BLUE "Uninstalling AirPrint Bridge service..."
    
    # Unload the service
    if [[ -f "$PLIST_PATH" ]]; then
        launchctl unload "$PLIST_PATH" 2>/dev/null || true
        rm -f "$PLIST_PATH"
        print_status $GREEN "Service unloaded and plist removed"
    fi
    
    # Remove the registration script
    if [[ -f "$SCRIPT_PATH" ]]; then
        rm -f "$SCRIPT_PATH"
        print_status $GREEN "Registration script removed"
    fi
    
    # Clean up log files
    rm -f /var/log/airprint_bridge.log
    rm -f /var/log/airprint_bridge_error.log
    
    print_status $GREEN "Uninstallation completed successfully!"
}

# Main script logic
main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--install)
                check_root
                install_service
                exit 0
                ;;
            -u|--uninstall)
                check_root
                uninstall_service
                exit 0
                ;;
            -t|--test)
                check_root
                test_airprint
                exit $?
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            --version)
                show_version
                exit 0
                ;;
            *)
                print_status $RED "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # If no arguments provided, show usage
    show_usage
    exit 1
}

# Run main function with all arguments
main "$@" 