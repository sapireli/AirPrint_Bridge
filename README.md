# 🖨️ AirPrint Bridge: Seamlessly Enable AirPrint for Non-AirPrint Printers on macOS [![Sponsor](https://img.shields.io/badge/Sponsor-❤️-ea4aaa?logo=github)](https://www.paypal.me/sapir)
Print Wirelessly from Your iPhone and iPad — No AirPrint Printer Required! Also, available at our docs [website](https://sapireli.github.io/AirPrint_Bridge)

## 📜 Description

AirPrint Bridge enables AirPrint functionality on macOS for printers that don't natively support it. This script allows iOS and iPadOS devices to print directly to printers that do not natively support AirPrint. The project doesn’t rely on any additional binaries that aren't built in on macOS, uses almost no resources, and is entirely automated. It naturally supports Apple’s Bonjour Sleep Proxy, so printers will continue to work when the host computer is asleep or rebooted (even pre-login).

![Bash Script](https://img.shields.io/badge/bash_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white) ![macOS](https://img.shields.io/badge/mac%20os-000000?style=for-the-badge&logo=macos&logoColor=F0F0F0) 

Developing and maintaining projects of this nature requires time and dedication. If you appreciate the effort, please feel free to show your support by giving this repository a ⭐.
---

## 📋 Table of Contents

- [⭐ Features](#-features)
- [🛠️ Requirements](#️-requirements)
- [💾 Installation](#-installation)
- [⚙️ Additional Options](#️-additional-options)
- [🗑️ Uninstallation](#️-uninstallation)
- [💡 How It Works](#-how-it-works)
- [❓ Troubleshooting](#-troubleshooting)
- [📄 License](#-license)
- [🙌 Acknowledgements](#-acknowledgements)
- [🤝 Contributing](#-contributing)
- [📜 Trademark Attribution](#-trademark-attribution)
- [🛡️ Disclaimer](#️-disclaimer)  

---

## ⭐ Features

- **Enable AirPrint for Non-AirPrint Printers**: Share printers that do not natively support AirPrint with your iOS devices.
- **Automatic Detection**: Automatically detects shared printers lacking AirPrint support.
- **Persistent Service**: Installs as a `launchd` service to ensure AirPrint functionality is always available.
- **Test Mode**: Run in test mode to verify functionality before installation.
- **Easy Uninstallation**: Clean removal of the script and associated services.
- **Bonjour Sleep Proxy**: Automatically registers with the sleep proxy so AirPrint services continue to work when the system is asleep.

## 🛠️ Requirements

- **Operating System**: macOS 10.15 (Catalina) or later. (Not officially tested on macOS versions prior to 10.15, but likely compatible.)
- **Shell**: Bash.
- A trusty old **printer**

## 💾 Installation

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

**Alternative: Install via Homebrew (Recommended)**

If you have Homebrew installed, you can install AirPrint Bridge directly:

```bash
# Add the tap and install
brew tap sapireli/AirPrint_Bridge https://github.com/sapireli/AirPrint_Bridge.git
brew install airprint-bridge
```

After Homebrew installation, you can use the `airprint-bridge` command directly.

**Note**: If you encounter git authentication issues, the explicit HTTPS URL ensures the tap works without requiring login credentials.

### 4. Test the Script

Run the script in **test mode**:

```bash
# If installed manually:
sudo ./airprint_bridge.sh -t

# If installed via Homebrew:
sudo airprint-bridge -t
```

What happens:

1. Detects local shared printers that lack AirPrint support.
2. Checks and fixes firewall and cups config as required
3. Generates a registration script (`airprint_bridge_launcher.sh`) to register printers via `dns-sd`.
4. Runs that registration script in the foreground so you can test printing from an iOS device.

The script will now hang while advertising your printers. If you can see and use your printer from iOS, you’re ready to install. **Use `CTRL-C`** to terminate.

### 5. Install the Service

```bash
# If installed manually:
sudo ./airprint_bridge.sh -i

# If installed via Homebrew:
sudo airprint-bridge -i
```

- Detects local shared printers that lack AirPrint support.
- Generates (or updates) the registration script.
- Creates and loads a `launchd` plist so your printers are always advertised at startup/reboot.

### 6. Verify Installation

Open an app on your iOS device with printing capabilities (Safari, Mail, Photos, etc.), tap **Print**, and choose the newly advertised printer(s).
Happy Printing!

## ⚙️ Additional Options

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

## 🗑️ Uninstallation

To remove AirPrint Bridge entirely:

```bash
# If installed manually:
sudo ./airprint_bridge.sh -u

# If installed via Homebrew:
sudo airprint-bridge -u
```

- Unloads and removes the `launchd` plist file.
- Deletes the registration script from `/usr/local/bin`.
- Restores cups config changes if previously modified by script.
- Terminates any running `dns-sd` processes associated with AirPrint Bridge. (skips gracefully if none are found)

Your system will be returned to its original state (i.e., as if AirPrint Bridge was never installed).

## 💡 How It Works

1. **Printer Detection**: Identifies all shared printers on your Mac; filters out those already AirPrint-capable.
2. **Capability Analysis**: Generates a suitable URF string based on each printer’s capabilities (color, duplex, paper types, etc.).
3. **Bonjour Registration**: Uses `dns-sd` to advertise each printer under the `_ipp._tcp.,_universal` service type.
4. **Launchd Integration**: Automatically starts and keeps the advertising service running in the background, even before user login.
5. **Bonjour Sleep Proxy**: macOS’s built-in Bonjour Sleep Proxy keeps these printers discoverable to iOS devices, even if the Mac is sleeping.

## ❓ Troubleshooting

### General Checks
- **Printers Not Found**: Confirm printers are installed, powered on, and marked “Shared” on your Mac.
- **Dependencies Missing**: Ensure `dns-sd`, `lpstat`, `lpoptions`, and `launchctl` are available (standard on macOS).
- **Permission Issues**: Use `sudo` for testing (`-t`), installation (`-i`), or uninstallation (`-u`).
- **Firewall Issues**: Allow incoming mDNS (UDP 5353) and IPP (TCP 631) or disable the firewall while testing.
- **No Output in Log**: If you enabled logging but see no file, ensure the script has permission to create/write the file.
- **Phantom Printer Remains**: Toggle macOS **Printer Sharing** off and back on if a printer still appears after uninstalling.
- **Network Access**: Ensure the iOS device and bridge host are on the same Wi‑Fi/subnet, with no guest SSID, VLAN, client-isolation, or VPN blocking multicast.
- **Static IP/DHCP Reservation**: Ensure a stable DHCP reservation or static IP address for the AirPrint bridge host so clients can consistently reach it.

### iOS Specific Checks
- **Network Consistency**: Confirm the device is on the same Wi-Fi network and no VPN is active.
- **mDNS/Bonjour Browser**: Use a Bonjour browser app (e.g., “Discovery – DNS‑SD Browser”) to confirm `_ipp._tcp` is visible and that the advertised host can be resolved to an IP:port.
- **Clear Caches**: Toggle Wi‑Fi or reboot the iOS device to clear mDNS caches.
- **Network Analyzer**: Use a Network Analyzer app to ping the bridge host and test connection to TCP port 631 (IPP).

### Manual Verification & Fixes

#### 1. Set AirPrint Bridge Hostname
If the hostname is blank or inconsistent, it can cause discovery issues:
```bash
# Check current hostname
scutil --get HostName

# Set a consistent hostname (if needed)
sudo scutil --set HostName <BRIDGE_HOSTNAME>
sudo killall mDNSResponder
```

#### 2. Verify Advertised Services
Run these commands from another Mac or the same host to verify the service is active and check TXT records:
```bash
# Browse for IPP services
dns-sd -B _ipp._tcp

# Look up specific service details (use the name found above)
dns-sd -L "<Registered Service Name>" _ipp._tcp local
```
*Look for `pdl`, `rp`, `URF`, `TLS`, `Duplex`, etc., in the TXT output.*

#### 3. Check IPP Reachability
Ensure the IPP port is open and responding:
```bash
# Check port 631
nc -vz <BRIDGE_HOST> 631

# Test IPP response
curl -I http://<BRIDGE_HOST>:631
```

## 📄 License

This project is licensed under the MIT License.

## 🙌 Acknowledgements

- Inspired by [@PeterCrozier](https://github.com/PeterCrozier/AirPrint)
- Insights from [GeekBitZone’s AirPrint guide](https://www.geekbitzone.com/posts/2021/macos/airprint/macos-airprint/)

## 🤝 Contributing

Feedback, bug reports, and pull requests are encouraged and appreciated. Feel free to open an issue on GitHub.

## 🌟 Give It a Star ⭐

If you find this project useful or interesting, please consider giving it a star on [GitHub](https://github.com/sapireli/AirPrint_Bridge). Your support helps others discover the project and motivates further improvements. Thank you! 😊

---

## 📜 Trademark Attribution

AirPrint, iPhone, iPad, Mac, and macOS are trademarks of Apple Inc., registered in the U.S. and other countries. Bonjour is a trademark of Apple Inc. Other trademarks and trade names may be used in this project to refer to entities claiming the marks and names of their respective products. Use of these trademarks does not imply any affiliation with or endorsement by their respective owners.

---

## 🛡️ Disclaimer

This script is provided "as is," without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, or non-infringement. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.

---
## 🔍 SEO Keywords

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
- Airprint Enabler
- AirPrint Hacktivator
- enable AirPrint on older printers
- make non-AirPrint printers AirPrint compatible
- print fron an iphone to a non-AirPrint compatible printer
- free alternative to Handyprint
- iOS Airprint Sharing on Mac OS
- iOS AirPrint for Mac
- enable AirPrint for any printer
- Airprint proxy
- How to turn your Mac into an AirPrint server using Airprint Bridge
