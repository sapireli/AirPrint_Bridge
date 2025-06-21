# Homebrew Tap for AirPrint Bridge

This repository contains the Homebrew formula for [AirPrint Bridge](https://github.com/sapireli/AirPrint_Bridge), a tool that seamlessly enables AirPrint functionality for non-AirPrint printers on macOS.

## Installation

### Option 1: Install via Homebrew Tap (Recommended)

```bash
# Add this tap
brew tap sapireli/airprint-bridge

# Install AirPrint Bridge
brew install airprint-bridge
```

### Option 2: Install directly from GitHub

```bash
# Install directly from this repository
brew install sapireli/airprint-bridge/airprint-bridge
```

## Usage

After installation, you can use AirPrint Bridge with the following commands:

```bash
# Test the installation
sudo airprint-bridge -t

# Install the service
sudo airprint-bridge -i

# Uninstall the service
sudo airprint-bridge -u

# Show help
airprint-bridge --help
```

## Requirements

- macOS 10.15 (Catalina) or later
- Printer sharing enabled in System Settings
- Root privileges for installation and uninstallation

## Documentation

For detailed documentation, visit: https://sapireli.github.io/AirPrint_Bridge/

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/sapireli/AirPrint_Bridge/blob/main/LICENSE) file for details.

## Contributing

Contributions are welcome! Please see the [Contributing Guide](https://sapireli.github.io/AirPrint_Bridge/docs/contributing) for details. 