# AirPrint Bridge: Seamlessly Enable AirPrint for Non-AirPrint Printers on macOS
Print Wirelessly from Your iPhone and iPad—No AirPrint Printer Required!


## Description

AirPrint Bridge is enabling AirPrint functionality on macOS for printers that don't natively support it. This script allows iOS and iPadOS devices to print directly to printers that do not natively support AirPrint. The project doesnt rely on any language or binary that isn't built in on macOS, utilizes (almost) no resources, and is entirely automated. Additionally, it naturally supports Apple's Bonjour Sleep Proxy so the printers will continue to work when the host computer is asleep or rebooted in pre-logged-in state.

---

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Usage Instructions](#usage-instructions)
- [Uninstallation](#uninstallation)
- [How It Works](#how-it-works)
- [Troubleshooting](#troubleshooting)
- [License](#license)
- [Acknowledgements](#acknowledgements)
- [Contributing](#contributing)
---

## Features

- **Enable AirPrint for Non-AirPrint Printers**: Share printers that do not natively support AirPrint with your iOS devices.
- **Automatic Detection**: Automatically detects shared printers lacking AirPrint support.
- **Persistent Service**: Installs as a `launchd` service to ensure AirPrint functionality is always available.
- **Test Mode**: Run in test mode to verify functionality before installation.
- **Easy Uninstallation**: Clean removal of the script and associated services.
- **Bonjour Sleep Proxy**: Automatically registers with the sleep proxy so Airprint Services continue to work when the system is asleep.

## Requirements

- **Operating System**: macOS 10.15 (Catalina) or later. Note: Not officially tested on macOS versions prior to Catalina (10.15) but probably will work.
- **Shell**: Bash.
- **Dependencies**:
  - `dns-sd`
  - `lpstat`
  - `lpoptions`
  - `launchctl`

Also:

  - A clunky old printer that still works.

## Usage Instructions

### 1. Share the printer(s)

Enable printer sharing through System Settings > General > Sharing (or Sharing in older macOS versions) by turning on Printer Sharing and selecting the printer(s) you want to share from the list. Alternatively, go to System Settings > Printers & Scanners, select the desired printer(s), and check "Share this printer on the network". Once sharing is enabled, continue to Step 2 below.

### 2. Download the Script

Clone the repository or download the `airprint_bridge.sh` script directly.

```bash
git clone https://github.com/yourusername/airprint-bridge.git
cd airprint-bridge
```

### 3. Make the Script Executable

Run Terminal.app from Applications/Utilities and browse to the directory you downloaded the script to (usually ```cd Downloads ```) 

Make the script executable.

```bash
chmod +x airprint_bridge.sh
```

### 4. Run the Script with the test option

Execute the script with the --test option.

```bash
./airprint_bridge.sh -t
```
What it does:
- Detect all local shared printers without AirPrint support.
- Generates a registration script (`airprint_bridge.sh`) to register printers via `dns-sd`.
- Runs `airprint_bridge.sh`to enable Airprint printing to detected printers (in the foreground).

This will then hang. While it is running the Mac should be acting as an Airprint server. Try to print from some iOS app to verify this. You can use CTRL-C to break the hang and exit the script. If everything works proceed to install below.
 
### 5. Run the Script with the install option to install

Execute the script with the --install option. **Note:** Installation requires `sudo` privileges.

```bash
sudo ./airprint_bridge.sh -i
```

- Detects all local shared printers without AirPrint support.
- Generates a registration script (`airprint_bridge.sh`) to register printers via `dns-sd`.
- Creates and loads a `launchd` plist file to run the script at startup.

### 7. Verify Installation

On your iOS device, open an app that supports printing (e.g., Safari, Mail) and attempt to print. Your shared printers should now appear in the printer selection menu.

## Usage Notes

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

- Inspired by [@PeterCrozier](https://github.com/PeterCrozier/AirPrint), with multiple enhancements for robustness, limited dependencies, and modern macOS compatibility.
- Based on ideas and insights from [GeekBitZone's guide to AirPrint on macOS](https://www.geekbitzone.com/posts/2021/macos/airprint/macos-airprint/), which provides a detailed explanation of enabling AirPrint support manually.


---

## SEO Keywords

- AirPrint macOS
- Enable AirPrint for non-AirPrint printers
- Print from iPhone macOS
- Bonjour AirPrint setup
- AirPrint for older printers
- macOS AirPrint bridge
- Free AirPrint solution
- Wireless printing macOS iPhone
- iPad printing non-AirPrint printer
- Add AirPrint support macOS
- Print wirelessly from iPhone to any printer
- Open source AirPrint solution
- Convert non-AirPrint printers to AirPrint
- macOS AirPrint script
- iOS printing non-AirPrint
- Turn macOS into AirPrint server
- AirPrint macOS Catalina
- Share printers with iPhone
- AirPrint script for Mac
- AirPrint without new hardware
- Affordable AirPrint solution
- DIY AirPrint setup
- AirPrint compatibility macOS
- Wireless printing iOS devices
- Enable AirPrint on legacy printers
- Easy AirPrint configuration
- macOS AirPrint automation
- Bonjour printer sharing macOS
- Turn shared printers into AirPrint devices
- Free macOS printing solution
- iPhone printing with shared printers
- AirPrint for older macOS versions
- How to AirPrint with macOS
- Hack to allow AirPrint print sharing on a Mac

**Keywords**: AirPrint, macOS, iOS, Printer Sharing, Bash Script, Bonjour, DNS-SD, CUPS, Non-AirPrint Printers, Network Printing, Printer Discovery, Launchd, Automation, Printing from iPhone, Printing from iPad.
## Contributing
Welcome all feedback, bug reports, and contributions to make AirPrint Bridge even better! Feel free to open an issue or submit a pull request.

