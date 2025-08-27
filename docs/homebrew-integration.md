---
sidebar_position: 3
---

# 🍺 Homebrew Integration

AirPrint Bridge is available through Homebrew, making installation and updates simple and reliable.

## What is Homebrew?

Homebrew is a package manager for macOS that simplifies the installation of software. It provides:

- **Easy Installation**: One command to install software
- **Automatic Updates**: Simple commands to keep software up to date
- **Dependency Management**: Automatically handles software dependencies
- **Clean Uninstallation**: Easy removal of installed software

## Installation via Homebrew

### Quick Install

```bash
# Add the tap and install
brew tap sapireli/AirPrint_Bridge https://github.com/sapireli/AirPrint_Bridge.git
brew install airprint-bridge
```

**Note**: The explicit HTTPS URL ensures the tap works without requiring git authentication credentials, even though the repository is public.

### Step-by-Step Installation

1. **Add the tap** (if not already added):
   ```bash
   brew tap sapireli/AirPrint_Bridge https://github.com/sapireli/AirPrint_Bridge.git
   ```

2. **Install AirPrint Bridge**:
   ```bash
   brew install airprint-bridge
   ```

3. **Test the installation**:
   ```bash
   sudo airprint-bridge -t
   ```

4. **Install the service**:
   ```bash
   sudo airprint-bridge -i
   ```

## Benefits of Homebrew Installation

### ✅ Easy Installation
- Single command installation
- No need to clone repositories or download files manually
- Automatic dependency resolution

### ✅ Simple Updates
```bash
# Update Homebrew and upgrade AirPrint Bridge
brew update
brew upgrade airprint-bridge
```

### ✅ Clean Uninstallation
```bash
# Uninstall the service first
sudo airprint-bridge -u

# Remove the package
brew uninstall airprint-bridge
```

### ✅ Professional Distribution
- Available to all Homebrew users
- Automatic formula validation
- Consistent installation experience

## Troubleshooting

### Git Authentication Issues

If you encounter git authentication prompts when tapping:

```bash
# Force HTTPS instead of SSH
git config --global url."https://github.com/".insteadOf git@github.com:

# Clear any cached credentials
git config --global --unset credential.helper

# Then try tapping again
brew tap sapireli/AirPrint_Bridge https://github.com/sapireli/AirPrint_Bridge.git
```

### Alternative Tapping Method

If you continue to have issues, you can also clone and tap locally:

```bash
# Clone the repository
git clone https://github.com/sapireli/AirPrint_Bridge.git
cd AirPrint_Bridge

# Tap from local directory
brew tap sapireli/AirPrint_Bridge .

# Install
brew install airprint-bridge
```

## Using AirPrint Bridge with Homebrew

### Command Reference

All AirPrint Bridge commands work the same way with Homebrew installation:

```bash
# Test functionality
sudo airprint-bridge -t

# Install the service
sudo airprint-bridge -i

# Uninstall the service
sudo airprint-bridge -u

# Show help
airprint-bridge --help

# Show version
airprint-bridge --version
```

### File Locations

With Homebrew installation, files are installed to standard locations:

- **Executable**: `/usr/local/bin/airprint-bridge`
- **Documentation**: `/usr/local/share/doc/airprint-bridge/`
- **License**: `/usr/local/share/airprint-bridge/LICENSE`

### Service Management

The service is managed through `launchd` and works identically to manual installation:

```bash
# Check service status
sudo launchctl list | grep airprint

# View service logs
sudo log show --predicate 'process == "airprint_bridge"'
```

## Updating AirPrint Bridge

### Automatic Updates

Homebrew makes updating simple:

```bash
# Update Homebrew's package database
brew update

# Upgrade AirPrint Bridge to the latest version
brew upgrade airprint-bridge

# Or upgrade all packages including AirPrint Bridge
brew upgrade
```

### What Happens During Updates

1. **New Version Download**: Homebrew downloads the latest version
2. **Service Uninstallation**: The old service is automatically uninstalled
3. **New Version Installation**: The new version is installed
4. **Service Reinstallation**: You'll need to reinstall the service:
   ```bash
   sudo airprint-bridge -i
   ```

### Checking for Updates

```bash
# Check if updates are available
brew outdated

# See what would be updated
brew upgrade --dry-run
```

## Troubleshooting Homebrew Installation

### Installation Issues

**Problem**: `brew install airprint-bridge` fails

**Solutions**:
- Update Homebrew: `brew update`
- Check formula syntax: `brew audit --strict --online sapireli/airprint-bridge/airprint-bridge`
- Try installing with verbose output: `brew install -v airprint-bridge`

### Permission Issues

**Problem**: Permission errors during installation or usage

**Solutions**:
- Ensure you're using `sudo` for service commands
- Check Homebrew permissions: `brew doctor`
- Fix Homebrew permissions if needed: `sudo chown -R $(whoami) /usr/local`

### Service Issues

**Problem**: Service doesn't start or work properly

**Solutions**:
- Reinstall the service: `sudo airprint-bridge -u && sudo airprint-bridge -i`
- Check service logs: `sudo log show --predicate 'process == "airprint_bridge"'`
- Verify file permissions: `ls -la /usr/local/bin/airprint-bridge`

### Update Issues

**Problem**: Updates fail or cause problems

**Solutions**:
- Clean Homebrew cache: `brew cleanup`
- Reinstall the formula: `brew uninstall airprint-bridge && brew install airprint-bridge`
- Check for conflicting packages: `brew deps --installed`

## Homebrew vs Manual Installation

| Feature | Homebrew | Manual |
|---------|----------|--------|
| Installation | `brew install airprint-bridge` | Clone repo, make executable |
| Updates | `brew upgrade airprint-bridge` | `git pull`, reinstall |
| Uninstallation | `brew uninstall airprint-bridge` | `sudo ./airprint_bridge.sh -u` |
| Dependencies | Automatic | Manual |
| File Locations | Standard Homebrew paths | Current directory |
| Professional | ✅ Yes | ❌ No |

## Advanced Homebrew Usage

### Installing Specific Versions

```bash
# Install a specific version (if available)
brew install sapireli/airprint-bridge/airprint-bridge@1.0.0
```

### Building from Source

```bash
# Build from source instead of using pre-built binary
brew install --build-from-source airprint-bridge
```

### Formula Information

```bash
# View formula details
brew info airprint-bridge

# View formula dependencies
brew deps airprint-bridge

# View formula options
brew options airprint-bridge
```

### Homebrew Tap Management

```bash
# List installed taps
brew tap

# Remove the tap (if needed)
brew untap sapireli/airprint-bridge

# Update the tap
brew tap --repair
```

## Contributing to the Homebrew Formula

If you want to contribute to the Homebrew formula:

1. **Fork the tap repository**: `sapireli/homebrew-airprint-bridge`
2. **Make your changes** to the formula
3. **Test your changes**:
   ```bash
   brew audit --strict --online Formula/airprint-bridge.rb
   brew install --build-from-source Formula/airprint-bridge.rb
   ```
4. **Submit a pull request**

## Resources

- [Homebrew Documentation](https://docs.brew.sh/)
- [Homebrew Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [Homebrew Tap Documentation](https://docs.brew.sh/Taps)
- [AirPrint Bridge Homebrew Tap](https://github.com/sapireli/homebrew-airprint-bridge)

## Next Steps

- [Installation Guide](/docs/installation) - Complete installation instructions
- [Troubleshooting](/docs/troubleshooting) - Common issues and solutions
- [Advanced Configuration](/docs/advanced-configuration) - Advanced setup options 