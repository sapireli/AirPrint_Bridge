---
sidebar_position: 1
---

# 🖨️ AirPrint Bridge

**Seamlessly Enable AirPrint for Non-AirPrint Printers on macOS**

Print wirelessly from your iPhone and iPad — no AirPrint printer required!

![Bash Script](https://img.shields.io/badge/bash_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white) ![macOS](https://img.shields.io/badge/mac%20os-000000?style=for-the-badge&logo=macos&logoColor=F0F0F0) ![License](https://img.shields.io/badge/license-MIT-blue.svg?style=for-the-badge) ![Homebrew](https://img.shields.io/badge/homebrew-%23FBB040.svg?style=for-the-badge&logo=homebrew&logoColor=white)

## What is AirPrint Bridge?

AirPrint Bridge enables AirPrint functionality on macOS for printers that don't natively support it. This script allows iOS and iPadOS devices to print directly to printers that do not natively support AirPrint. The project doesn't rely on any additional binaries that aren't built in on macOS, uses almost no resources, and is entirely automated.

## ✨ Key Features

- **🖨️ Enable AirPrint for Non-AirPrint Printers**: Share printers that do not natively support AirPrint with your iOS devices
- **🔍 Automatic Detection**: Automatically detects shared printers lacking AirPrint support
- **🔄 Persistent Service**: Installs as a `launchd` service to ensure AirPrint functionality is always available
- **🧪 Test Mode**: Run in test mode to verify functionality before installation
- **🗑️ Easy Uninstallation**: Clean removal of the script and associated services
- **💤 Bonjour Sleep Proxy**: Automatically registers with the sleep proxy so AirPrint services continue to work when the system is asleep
- **🍺 Homebrew Support**: Available via Homebrew for easy installation and updates

## 🛠️ Requirements

- **Operating System**: macOS 10.15 (Catalina) or later
- **Shell**: Bash
- **Printer**: Any printer that can be shared on macOS

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
- **Homebrew Integration**: Easy installation and updates via Homebrew

## 📄 License

This project is licensed under the MIT License - see the [License](/docs/license) page for details.

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](/docs/contributing) for details.

## ⭐ Support the Project

If you find this project useful, please consider giving it a star on [GitHub](https://github.com/sapireli/AirPrint_Bridge). Your support helps others discover the project and motivates further improvements.

---

**Ready to get started?** Check out our [Installation Guide](/docs/installation) for detailed setup instructions, or learn more about [Homebrew Integration](/docs/homebrew-integration).
