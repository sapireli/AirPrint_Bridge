# Homebrew Tap for AirPrint Bridge

This is the Homebrew tap for [AirPrint Bridge](https://github.com/sapireli/AirPrint_Bridge), a tool that enables AirPrint functionality for non-AirPrint printers on macOS.

## For Users

### Installation

```bash
# Add the tap and install
brew tap sapireli/airprint-bridge
brew install airprint-bridge
```

### Usage

After installation, you can use the `airprint-bridge` command:

```bash
# Test the installation
sudo airprint-bridge -t

# Install the service
sudo airprint-bridge -i

# Uninstall
sudo airprint-bridge -u
```

## For Tap Maintainers

### Setting up the tap

1. Create a new repository named `homebrew-airprint-bridge` in the `sapireli` organization
2. Copy the `airprint-bridge.rb` formula to that repository
3. The tap will then be available at `sapireli/airprint-bridge`

### Updating the formula

When updating the main AirPrint Bridge project:

1. Update the version number in `airprint-bridge.rb`
2. Update the SHA256 hash (you can get this by running `shasum -a 256` on the downloaded tarball)
3. Commit and push the changes

## What it does

AirPrint Bridge enables AirPrint functionality on macOS for printers that don't natively support it. This allows iOS and iPadOS devices to print directly to printers that do not natively support AirPrint.

## Requirements

- macOS 10.15 (Catalina) or later
- Printers must be shared via macOS Printer Sharing

## More Information

For detailed documentation, visit: https://github.com/sapireli/AirPrint_Bridge
