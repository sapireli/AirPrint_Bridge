---
sidebar_position: 2
---

# 📥 Installation Guide

Complete step-by-step instructions for installing and configuring AirPrint Bridge on your macOS system.

## Prerequisites

Before installing AirPrint Bridge, ensure you have:

- **macOS 10.15 (Catalina) or later**
- **Administrator privileges** (for installation)
- **A printer connected to your Mac** (USB, network, or shared)
- **Terminal access**

## Step 1: Share Your Printers

First, you need to share your printers on macOS:

### For macOS Ventura and newer:
1. Open **System Settings**
2. Go to **General > Sharing**
3. Enable **Printer Sharing**
4. Select the printer(s) you want to share

### For older macOS versions:
1. Open **System Preferences**
2. Go to **Sharing**
3. Check the box for **Printer Sharing**
4. Select the printer(s) you want to share

### Alternative method:
1. Go to **System Settings > Printers & Scanners**
2. Select your printer
3. Enable "Share this printer on the network"

## Step 2: Install AirPrint Bridge

### Option A: Install via Homebrew (Recommended)

Homebrew provides the easiest and most reliable installation method:

```bash
# Add the tap and install
brew tap sapireli/AirPrint_Bridge https://github.com/sapireli/AirPrint_Bridge.git
brew install airprint-bridge
```

**Benefits of Homebrew installation:**
- ✅ One-command installation
- ✅ Automatic updates via `brew upgrade`
- ✅ Proper dependency management
- ✅ Easy uninstallation with `brew uninstall airprint-bridge`
- ✅ Professional distribution channel

### Option B: Manual Installation

If you prefer to install manually or don't have Homebrew:

#### Download AirPrint Bridge

```bash
# Clone the repository
git clone https://github.com/sapireli/AirPrint_Bridge.git
cd AirPrint_Bridge
```

#### Make the Script Executable

```bash
chmod +x airprint_bridge.sh
```

## Step 3: Test the Installation

Before installing permanently, test the script to ensure it works with your setup:

### For Homebrew Installation:
```bash
sudo airprint-bridge -t
```

### For Manual Installation:
```bash
sudo ./airprint_bridge.sh -t
```

**What happens during testing:**
1. The script detects your shared printers
2. Checks and fixes firewall and CUPS configuration as needed
3. Generates a registration script
4. Runs the registration script in the foreground
5. Your printers should now appear on iOS devices

**To stop the test:**
- Press `Ctrl+C` to terminate the test
- If you can see and use your printer from iOS, you're ready to install

## Step 4: Install the Service

Once testing is successful, install the permanent service:

### For Homebrew Installation:
```bash
sudo airprint-bridge -i
```

### For Manual Installation:
```bash
sudo ./airprint_bridge.sh -i
```

**What happens during installation:**
1. Detects shared printers lacking AirPrint support
2. Generates (or updates) the registration script
3. Creates and loads a `launchd` plist
4. Your printers are now permanently advertised at startup/reboot

## Step 5: Verify Installation

1. **On your iOS device:**
   - Open any app with printing capabilities (Safari, Mail, Photos, etc.)
   - Tap **Print**
   - Look for your newly advertised printer(s)

2. **Check the service status:**
   ```bash
   sudo launchctl list | grep airprint
   ```

## Advanced Configuration

### Custom Script Location

You can specify a custom location for the registration script:

#### For Homebrew Installation:
```bash
sudo airprint-bridge -i -f /path/to/custom_launcher.sh
```

#### For Manual Installation:
```bash
sudo ./airprint_bridge.sh -i -f /path/to/custom_launcher.sh
```

### Enable Logging

To enable verbose logging for debugging:

1. Open the script in a text editor:
   - **Homebrew**: `/usr/local/bin/airprint-bridge`
   - **Manual**: `airprint_bridge.sh` in your cloned directory
2. Find the line: `LOGGING=0`
3. Change it to: `LOGGING=1`
4. Save the file
5. Reinstall the service

Logs will be written to `airprint_bridge.log` in the script's directory.

### Firewall Configuration

The script automatically configures macOS firewall settings. If you encounter issues:

1. Go to **System Settings > Network > Firewall**
2. Ensure "Printer Sharing" is allowed
3. Check that Bonjour services are not blocked

## Troubleshooting

### Printers Not Found

**Problem:** iOS devices can't see the advertised printers

**Solutions:**
- Verify printers are shared in System Settings
- Check that printers are powered on and connected
- Ensure both devices are on the same network
- Restart the AirPrint Bridge service:
  ```bash
  # For Homebrew installation
  sudo airprint-bridge -u
  sudo airprint-bridge -i
  
  # For manual installation
  sudo ./airprint_bridge.sh -u
  sudo ./airprint_bridge.sh -i
  ```

### Permission Issues

**Problem:** "Permission denied" errors during installation

**Solutions:**
- Ensure you're using `sudo` for installation commands
- Check that the script is executable: `chmod +x airprint_bridge.sh`
- Verify you have administrator privileges

### Service Not Starting

**Problem:** AirPrint Bridge doesn't start automatically

**Solutions:**
- Check the service status: `sudo launchctl list | grep airprint`
- View system logs: `sudo log show --predicate 'process == "airprint_bridge"'`
- Reinstall the service:
  ```bash
  # For Homebrew installation
  sudo airprint-bridge -u && sudo airprint-bridge -i
  
  # For manual installation
  sudo ./airprint_bridge.sh -u && sudo ./airprint_bridge.sh -i
  ```

### Network Issues

**Problem:** Printers work locally but not from other devices

**Solutions:**
- Ensure both devices are on the same network
- Check router settings for multicast traffic
- Verify Bonjour/mDNS is not blocked
- Try restarting your network equipment

## Uninstallation

### For Homebrew Installation:
```bash
# Uninstall the service first
sudo airprint-bridge -u

# Then remove the package
brew uninstall airprint-bridge
```

### For Manual Installation:
```bash
sudo ./airprint_bridge.sh -u
```

This will:
- Unload and remove the `launchd` plist file
- Delete the registration script from `/usr/local/bin`
- Restore CUPS configuration changes
- Terminate any running `dns-sd` processes

## Updating AirPrint Bridge

### For Homebrew Installation:
```bash
# Update Homebrew and upgrade AirPrint Bridge
brew update
brew upgrade airprint-bridge
```

### For Manual Installation:
```bash
# Pull the latest changes
git pull origin main

# Reinstall the service
sudo ./airprint_bridge.sh -u
sudo ./airprint_bridge.sh -i
```

## Next Steps

- Learn about [troubleshooting common issues](/docs/troubleshooting)
- Check out [advanced configuration options](/docs/advanced-configuration)
- Read about [how AirPrint Bridge works](/docs/how-it-works)
- Join the [community discussions](https://github.com/sapireli/AirPrint_Bridge/discussions) 