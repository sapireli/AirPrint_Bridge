# 🖨️ AirPrint Bridge

**Seamlessly Enable AirPrint for Non-AirPrint Printers on macOS**

Print wirelessly from your iPhone and iPad — no AirPrint printer required!

![Bash Script](https://img.shields.io/badge/bash_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white) ![macOS](https://img.shields.io/badge/mac%20os-000000?style=for-the-badge&logo=macos&logoColor=F0F0F0) ![License](https://img.shields.io/badge/license-MIT-blue.svg?style=for-the-badge)

## 📜 Description

AirPrint Bridge enables AirPrint functionality on macOS for printers that don't natively support it. This script allows iOS and iPadOS devices to print directly to printers that do not natively support AirPrint. The project doesn't rely on any additional binaries that aren't built in on macOS, uses almost no resources, and is entirely automated. It naturally supports Apple's Bonjour Sleep Proxy, so printers will continue to work when the host computer is asleep or rebooted (even pre-login).

## 🚀 Quick Start

### 1. Share Your Printers

Enable printer sharing via:
- **System Settings > General > Sharing** (macOS Ventura and newer), or
- **System Preferences > Sharing** (older macOS versions)

Check the box for **Printer Sharing** and select the printer(s) you'd like to share.

### 2. Install AirPrint Bridge

#### Option A: Install via Homebrew (Recommended)

```bash
# Add the tap and install
brew tap sapireli/airprint-bridge
brew install airprint-bridge

# Test the installation
sudo airprint-bridge -t

# Install the service
sudo airprint-bridge -i
```

#### Option B: Manual Installation

```bash
# Clone the repository
git clone https://github.com/sapireli/AirPrint_Bridge.git
cd AirPrint_Bridge

# Make the script executable
chmod +x airprint_bridge.sh

# Test the script first
sudo ./airprint_bridge.sh -t

# Install the service
sudo ./airprint_bridge.sh -i
```

### 3. Start Printing

Open an app on your iOS device with printing capabilities (Safari, Mail, Photos, etc.), tap **Print**, and choose the newly advertised printer(s).

## ✨ Key Features

- **🖨️ Enable AirPrint for Non-AirPrint Printers**: Share printers that do not natively support AirPrint with your iOS devices
- **🔍 Automatic Detection**: Automatically detects shared printers lacking AirPrint support
- **🔄 Persistent Service**: Installs as a `launchd` service to ensure AirPrint functionality is always available
- **🧪 Test Mode**: Run in test mode to verify functionality before installation
- **🗑️ Easy Uninstallation**: Clean removal of the script and associated services
- **💤 Bonjour Sleep Proxy**: Automatically registers with the sleep proxy so AirPrint services continue to work when the system is asleep

## 📚 Documentation

📖 **Full Documentation**: [https://sapireli.github.io/AirPrint_Bridge/](https://sapireli.github.io/AirPrint_Bridge/)

The documentation includes:
- 📥 [Installation Guide](https://sapireli.github.io/AirPrint_Bridge/docs/installation)
- 🔧 [Troubleshooting](https://sapireli.github.io/AirPrint_Bridge/docs/troubleshooting)
- ⚙️ [Advanced Configuration](https://sapireli.github.io/AirPrint_Bridge/docs/advanced-configuration)
- 💡 [How It Works](https://sapireli.github.io/AirPrint_Bridge/docs/how-it-works)
- 🤝 [Contributing Guide](https://sapireli.github.io/AirPrint_Bridge/docs/contributing)

## 🛠️ Requirements

- **Operating System**: macOS 10.15 (Catalina) or later
- **Shell**: Bash
- **Printer**: Any printer that can be shared on macOS

## 💡 How It Works

1. **Printer Detection**: Identifies all shared printers on your Mac; filters out those already AirPrint-capable
2. **Capability Analysis**: Generates a suitable URF string based on each printer's capabilities (color, duplex, paper types, etc.)
3. **Bonjour Registration**: Uses `dns-sd` to advertise each printer under the `_ipp._tcp.,_universal` service type
4. **Launchd Integration**: Automatically starts and keeps the advertising service running in the background, even before user login
5. **Bonjour Sleep Proxy**: macOS's built-in Bonjour Sleep Proxy keeps these printers discoverable to iOS devices, even if the Mac is sleeping

## 🎯 Use Cases

- **Home Users**: Enable AirPrint for older printers without buying new hardware
- **Small Offices**: Share existing network printers with iOS devices
- **Developers**: Test printing functionality on iOS apps with any printer
- **Educational Institutions**: Enable students to print from iPads to existing infrastructure

## 🔧 Advanced Features

- **Custom Script Location**: Specify custom paths for the registration script
- **Verbose Logging**: Enable detailed logging for debugging
- **Test Mode**: Verify functionality before permanent installation
- **Clean Uninstallation**: Complete removal of all components

## 🗑️ Uninstallation

To remove AirPrint Bridge entirely:

```bash
sudo ./airprint_bridge.sh -u
```

This will:
- Unload and remove the `launchd` plist file
- Delete the registration script from `/usr/local/bin`
- Restore CUPS configuration changes if previously modified by script
- Terminate any running `dns-sd` processes associated with AirPrint Bridge

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](https://sapireli.github.io/AirPrint_Bridge/docs/contributing) for details.

### Development Setup

```bash
# Clone the repository
git clone https://github.com/sapireli/AirPrint_Bridge.git
cd AirPrint_Bridge

# Install documentation dependencies
npm install

# Start documentation development server
npm start

# Deploy documentation to GitHub Pages
./deploy.sh
```

### Deployment Process

The documentation is deployed using a two-step process:

1. **Build and Push**: The `deploy.sh` script builds the site and pushes it to the `gh-pages` branch
2. **GitHub Actions**: A GitHub Actions workflow automatically deploys the site from the `gh-pages` branch to GitHub Pages

This ensures that only the built site files are deployed, keeping the repository clean and the deployment process reliable.

## 📄 License

This project is licensed under the MIT License - see the [License](https://sapireli.github.io/AirPrint_Bridge/docs/license) page for details.

## 🙌 Acknowledgements

- Inspired by [@PeterCrozier](https://github.com/PeterCrozier/AirPrint)
- Insights from [GeekBitZone's AirPrint guide](https://www.geekbitzone.com/posts/2021/macos/airprint/macos-airprint/)

## 🌟 Give It a Star ⭐

If you find this project useful or interesting, please consider giving it a star on [GitHub](https://github.com/sapireli/AirPrint_Bridge). Your support helps others discover the project and motivates further improvements. Thank you! 😊

---

## 📜 Trademark Attribution

AirPrint, iPhone, iPad, Mac, and macOS are trademarks of Apple Inc., registered in the U.S. and other countries. Bonjour is a trademark of Apple Inc. Other trademarks and trade names may be used in this project to refer to entities claiming the marks and names of their respective products. Use of these trademarks does not imply any affiliation with or endorsement by their respective owners.

## 🛡️ Disclaimer

This script is provided "as is," without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, or non-infringement. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
