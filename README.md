# AirPrint Bridge: Seamlessly Enable AirPrint for Non-AirPrint Printers on macOS
Print Wirelessly from Your iPhone and iPad — No AirPrint Printer Required! [![GitHub last commit](https://img.shields.io/github/last-commit/sapireli/AirPrint_Bridge)

## Description

AirPrint Bridge enables AirPrint functionality on macOS for printers that don't natively support it. This script allows iOS and iPadOS devices to print directly to printers that do not natively support AirPrint. The project doesn’t rely on any additional binaries that aren't built in on macOS, uses almost no resources, and is entirely automated. It naturally supports Apple’s Bonjour Sleep Proxy, so printers will continue to work when the host computer is asleep or rebooted (even pre-login).

![Bash Script](https://img.shields.io/badge/bash_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white) ![macOS](https://img.shields.io/badge/mac%20os-000000?style=for-the-badge&logo=macos&logoColor=F0F0F0) 

---

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Usage Instructions](#usage-instructions)
- [Additional Options](#additional-options)
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
- **Bonjour Sleep Proxy**: Automatically registers with the sleep proxy so AirPrint services continue to work when the system is asleep.

## Requirements

- **Operating System**: macOS 10.15 (Catalina) or later. (Not officially tested on macOS versions prior to 10.15, but likely compatible.)
- **Shell**: Bash.
- **Dependencies**:
  - `dns-sd`
  - `lpstat`
  - `lpoptions`
  - `launchctl`

And of course, a trusty old printer!

## Usage Instructions

### 1. Share Your Printers

Enable printer sharing via:
- **System Settings > General > Sharing** (macOS Ventura and newer), or
- **System Preferences > Sharing** (older macOS versions)

Check the box for **Printer Sharing** and select the printer(s) you’d like to share. Alternatively, visit **System Settings > Printers & Scanners**, select the printer(s), and enable “Share this printer on the network.”

### 2. Download the Script

Clone the repository or download the `airprint_bridge.sh` script directly:

```bash
git clone https://github.com/sapireli/AirPrint_Bridge.git
cd AirPrint_Bridge
```

### 3. Make the Script Executable

Open **Terminal.app** and navigate to the folder where you saved the script (e.g., `cd Downloads`).

```bash
chmod +x airprint_bridge.sh
```

### 4. Test the Script

Run the script in **test mode**:

```bash
./airprint_bridge.sh -t
```

What happens:

1. Detects local shared printers that lack AirPrint support.
2. Generates a registration script (`airprint_bridge_launcher.sh`) to register printers via `dns-sd`.
3. Runs that registration script in the foreground so you can test printing from an iOS device.

The script will now hang while advertising your printers. If you can see and use your printer from iOS, you’re ready to install. **Use `CTRL-C`** to terminate.

### 5. Install the Service

```bash
sudo ./airprint_bridge.sh -i
```

- Detects local shared printers that lack AirPrint support.
- Generates (or updates) the registration script.
- Creates and loads a `launchd` plist so your printers are always advertised at startup/reboot.

### 6. Verify Installation

Open an app on your iOS device with printing capabilities (Safari, Mail, Photos, etc.), tap **Print**, and choose the newly advertised printer(s).
Happy Printing!

## Additional Options

### 1. Logging

By default, **logging** is disabled, so the script outputs only to the terminal (stderr). If you would like to enable verbose logging to a file named `airprint_bridge.log` in the script’s directory, open `airprint_bridge.sh` and set:

```bash
LOGGING=1
```

With `LOGGING=1`, any messages output by the script will also be appended to `airprint_bridge.log`. This is helpful for debugging or auditing the script’s activity.

### 2. Custom Script Filename (`-f`)

The `-f` option allows you to specify a **custom filename and/or location** for the generated AirPrint registration script. By default, the script is named `airprint_bridge_launcher.sh` and is created in the current working directory (then copied to `/usr/local/bin` during installation).

For example, to place the launcher script in a custom path:

```bash
./airprint_bridge.sh -t -f /path/to/custom_launcher.sh
```

This tells `airprint_bridge.sh` to generate `/path/to/custom_launcher.sh` rather than the default `airprint_bridge_launcher.sh`. This can be useful if you need the script in a specific location or under a specific name.

> **Note**: The `-f` option only overrides the generation of the **registration** script, not the main `airprint_bridge.sh` itself.

## Uninstallation

To remove AirPrint Bridge entirely:

```bash
sudo ./airprint_bridge.sh -u
```

- Unloads and removes the `launchd` plist file.
- Deletes the registration script from `/usr/local/bin`.
- Terminates any running `dns-sd` processes associated with AirPrint Bridge.

Your system will be returned to its original state (i.e., as if AirPrint Bridge was never installed).

## How It Works

1. **Printer Detection**: Identifies all shared printers on your Mac; filters out those already AirPrint-capable.
2. **Capability Analysis**: Generates a suitable URF string based on each printer’s capabilities (color, duplex, paper types, etc.).
3. **Bonjour Registration**: Uses `dns-sd` to advertise each printer under the `_ipp._tcp.,_universal` service type.
4. **Launchd Integration**: Automatically starts and keeps the advertising service running in the background, even before user login.
5. **Bonjour Sleep Proxy**: macOS’s built-in Bonjour Sleep Proxy keeps these printers discoverable to iOS devices, even if the Mac is sleeping.

## Troubleshooting

- **Printers Not Found**: Confirm the printers are installed, powered on, and marked “Shared” on your Mac.
- **Dependencies Missing**: Ensure that `dns-sd`, `lpstat`, `lpoptions`, and `launchctl` are installed (they are typically standard on macOS).
- **Permission Issues**: Use `sudo` for installation or uninstallation.
- **Firewall Issues**: Make sure printer sharing and Bonjour services aren’t blocked in your macOS firewall.
- **No Output in Log**: If you enabled logging but see no file, ensure the script has permission to create/write the file.

## License

This project is licensed under the MIT License.

## Acknowledgements

- Inspired by [@PeterCrozier](https://github.com/PeterCrozier/AirPrint)
- Insights from [GeekBitZone’s AirPrint guide](https://www.geekbitzone.com/posts/2021/macos/airprint/macos-airprint/)

## Contributing

Feedback, bug reports, and pull requests are encouraged and appreciated. Feel free to open an issue on GitHub.

## Give It a Star ⭐

If you find this project useful or interesting, please consider giving it a star on [GitHub](https://github.com/sapireli/AirPrint_Bridge). Your support helps others discover the project and motivates further improvements. Thank you! 😊

---

## SEO Keywords

- Enable AirPrint for non-AirPrint printers
- Print from iPhone to shared printer
- How To Print to iPhone or iPad With or Without AirPrint
- AirPrint for older printers
- macOS AirPrint bridge
- iPad printing non-AirPrint printer
- Add AirPrint support to printer macOS
- Print wirelessly from iPhone to any printer
- Open source AirPrint solution
- Convert non-AirPrint printers to AirPrint
- iOS printing non-AirPrint
- Turn macOS into AirPrint server
- AirPrint without new hardware
- free AirPrint solution
- Enable AirPrint on legacy printers
- Turn shared printers into AirPrint devices
- iPhone printing with shared printers
- Hack to allow AirPrint print sharing on a Mac
- Airprint Activator
- enable AirPrint on older printers
- make non-AirPrint printers AirPrint compatible
- print fron an iphone to a non-AirPrint compatible printer
- free alternative to Handyprint
