# AirPrint_Bridge
AirPrint Bridge: Add AirPrint Support to Unsupported Printers on macOS

# AirPrint Bridge: Enable AirPrint for Local Printers on macOS

## Description

AirPrint Bridge is a Bash script designed to enable AirPrint support for local printers shared on macOS. This allows iOS and iPadOS devices to print directly to printers that do not natively support AirPrint. The project draws inspiration from [PeterCrozier's AirPrint](https://github.com/PeterCrozier/AirPrint), enhancing and modernizing the approach to ensure compatibility with recent macOS versions.

---

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Uninstallation](#uninstallation)
- [How It Works](#how-it-works)
- [Troubleshooting](#troubleshooting)
- [License](#license)
- [Acknowledgements](#acknowledgements)

---

## Features

- **Enable AirPrint for Non-AirPrint Printers**: Share printers that do not natively support AirPrint with your iOS devices.
- **Automatic Detection**: Automatically detects shared printers lacking AirPrint support.
- **Persistent Service**: Installs as a `launchd` service to ensure AirPrint functionality is always available.
- **Test Mode**: Run in test mode to verify functionality before installation.
- **Easy Uninstallation**: Clean removal of the script and associated services.

## Requirements

- **Operating System**: macOS 10.15 (Catalina) or later.
- **Shell**: Bash.
- **Dependencies**:
  - `dns-sd`
  - `lpstat`
  - `lpoptions`
  - `launchctl`

## Installation

### 1. Download the Script

Clone the repository or download the `airprint_bridge.sh` script directly.

```bash
git clone https://github.com/yourusername/airprint-bridge.git
cd airprint-bridge
```

### 2. Make the Script Executable

```bash
chmod +x airprint_bridge.sh
```

### 3. Run the Installer

Execute the script with the install option. **Note:** Installation requires `sudo` privileges.

```bash
sudo ./airprint_bridge.sh --install
```

- Detects all local shared printers without AirPrint support.
- Generates a registration script (`airprint_bridge.sh`) to register printers via `dns-sd`.
- Creates and loads a `launchd` plist file to run the script at startup.

### 4. Verify Installation

On your iOS device, open an app that supports printing (e.g., Safari, Mail) and attempt to print. Your shared printers should now appear in the printer selection menu.

## Usage

### Test Mode

To test the script without installing it permanently:

```bash
./airprint_bridge.sh --test
```

- Detects and registers printers in the foreground.
- Use `CTRL-C` to exit test mode.

### Help

For usage information:

```bash
./airprint_bridge.sh --help
```

## Uninstallation

To completely remove the AirPrint Bridge and its services:

```bash
sudo ./airprint_bridge.sh --uninstall
```

- Unloads and removes the `launchd` plist file.
- Deletes the script from `/usr/local/bin`.
- Terminates any running `dns-sd` processes related to the AirPrint Bridge.

## How It Works

1. **Printer Detection**: Lists all local shared printers and filters out those that already support AirPrint.
2. **Capability Analysis**: Analyzes each printer's capabilities to generate appropriate AirPrint TXT records.
3. **Service Registration**: Generates a script that uses `dns-sd` to register printers with AirPrint service types (`_ipp._tcp.,_universal`).
4. **Persistent Launchd Service**: Creates a `launchd` plist file to run the registration script at startup.
5. **Bonjour Advertising**: The script advertises the printers over Bonjour, making them discoverable to iOS devices.

## Troubleshooting

- **Printers Not Found**: Ensure your printers are installed and shared on your macOS system.
- **Dependencies Missing**: Verify that `dns-sd`, `lpstat`, `lpoptions`, and `launchctl` are installed.
- **Permission Issues**: Installation and uninstallation require `sudo` privileges.
- **Printers Not Visible on iOS**: Check that your firewall settings allow incoming connections for printer sharing and Bonjour services.

## License

This project is licensed under the MIT License.

## Acknowledgements

- Inspired by [PeterCrozier's AirPrint](https://github.com/PeterCrozier/AirPrint), with enhancements for modern macOS compatibility.
- Utilizes standard macOS commands and services to bridge the gap between traditional printers and modern devices.

---

**Keywords**: AirPrint, macOS, iOS, Printer Sharing, Bash Script, Bonjour, DNS-SD, CUPS, Non-AirPrint Printers, Network Printing, Printer Discovery, Launchd, Automation, Printing from iPhone, Printing from iPad.
