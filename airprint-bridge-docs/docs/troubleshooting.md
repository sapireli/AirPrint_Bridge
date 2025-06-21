---
sidebar_position: 3
---

# 🔧 Troubleshooting Guide

Common issues and solutions for AirPrint Bridge. If you're experiencing problems, start here.

## Quick Diagnostic Commands

Run these commands to check your AirPrint Bridge installation:

```bash
# Check if the service is running
sudo launchctl list | grep airprint

# Check for any running dns-sd processes
ps aux | grep dns-sd

# View recent system logs
sudo log show --predicate 'process == "airprint_bridge"' --last 1h

# Check if the script exists and is executable
ls -la /usr/local/bin/airprint_bridge_launcher.sh

# Test printer detection
sudo ./airprint_bridge.sh -t
```

## Common Issues

### 🖨️ Printers Not Appearing on iOS Devices

**Symptoms:**
- AirPrint Bridge is installed and running
- iOS devices can't see the advertised printers
- Printers work locally on macOS

**Diagnostic Steps:**
1. **Check printer sharing:**
   ```bash
   lpstat -p -d
   ```

2. **Verify network connectivity:**
   ```bash
   ping -c 3 [your-ios-device-ip]
   ```

3. **Check Bonjour services:**
   ```bash
   dns-sd -B _ipp._tcp
   ```

**Solutions:**
- Ensure both devices are on the same network
- Restart the AirPrint Bridge service:
  ```bash
  sudo ./airprint_bridge.sh -u
  sudo ./airprint_bridge.sh -i
  ```
- Check firewall settings in System Settings > Network > Firewall
- Restart your router/network equipment

### 🔐 Permission Denied Errors

**Symptoms:**
- "Permission denied" when running the script
- Cannot create or modify files in `/usr/local/bin`

**Solutions:**
1. **Ensure you're using sudo:**
   ```bash
   sudo ./airprint_bridge.sh -i
   ```

2. **Check script permissions:**
   ```bash
   chmod +x airprint_bridge.sh
   ```

3. **Verify administrator privileges:**
   ```bash
   whoami
   groups
   ```

4. **Check SIP status (if applicable):**
   ```bash
   csrutil status
   ```

### 🚫 Service Not Starting Automatically

**Symptoms:**
- AirPrint Bridge works when run manually
- Service doesn't start after reboot
- `launchctl list` shows no airprint entries

**Diagnostic Steps:**
1. **Check launchd plist:**
   ```bash
   ls -la /Library/LaunchDaemons/com.airprint.bridge.plist
   ```

2. **View launchd logs:**
   ```bash
   sudo log show --predicate 'subsystem == "com.apple.launchd"' --last 1h
   ```

**Solutions:**
1. **Reinstall the service:**
   ```bash
   sudo ./airprint_bridge.sh -u
   sudo ./airprint_bridge.sh -i
   ```

2. **Check plist syntax:**
   ```bash
   plutil -lint /Library/LaunchDaemons/com.airprint.bridge.plist
   ```

3. **Load manually to test:**
   ```bash
   sudo launchctl load /Library/LaunchDaemons/com.airprint.bridge.plist
   ```

### 🌐 Network Connectivity Issues

**Symptoms:**
- Printers work locally but not from other devices
- Intermittent connectivity
- iOS devices can't connect to advertised printers

**Diagnostic Steps:**
1. **Check network interfaces:**
   ```bash
   ifconfig | grep inet
   ```

2. **Test multicast connectivity:**
   ```bash
   ping -c 3 224.0.0.251
   ```

3. **Check router settings:**
   - Ensure multicast traffic is allowed
   - Check for any mDNS/Bonjour blocking

**Solutions:**
- Restart network equipment
- Check router firewall settings
- Ensure both devices are on the same subnet
- Try connecting via Ethernet instead of Wi-Fi

### 📝 Logging Issues

**Symptoms:**
- No log file created when logging is enabled
- Can't find error messages
- Script runs but doesn't provide feedback

**Solutions:**
1. **Enable logging:**
   ```bash
   # Edit the script to enable logging
   sed -i '' 's/LOGGING=0/LOGGING=1/' airprint_bridge.sh
   ```

2. **Check log file location:**
   ```bash
   ls -la airprint_bridge.log
   ```

3. **View real-time logs:**
   ```bash
   tail -f airprint_bridge.log
   ```

### 🔄 CUPS Configuration Issues

**Symptoms:**
- Printers not detected by the script
- CUPS errors in system logs
- Printer sharing not working

**Diagnostic Steps:**
1. **Check CUPS status:**
   ```bash
   sudo launchctl list | grep cups
   ```

2. **View CUPS logs:**
   ```bash
   tail -f /var/log/cups/error_log
   ```

3. **Test CUPS configuration:**
   ```bash
   lpstat -t
   ```

**Solutions:**
1. **Restart CUPS:**
   ```bash
   sudo launchctl unload /System/Library/LaunchDaemons/org.cups.cupsd.plist
   sudo launchctl load /System/Library/LaunchDaemons/org.cups.cupsd.plist
   ```

2. **Reset CUPS configuration:**
   ```bash
   sudo rm /etc/cups/cupsd.conf
   sudo cp /etc/cups/cupsd.conf.default /etc/cups/cupsd.conf
   ```

### 🖥️ macOS Version Compatibility

**Symptoms:**
- Script fails on older macOS versions
- Different behavior between macOS versions
- Missing system components

**Solutions:**
- **Minimum requirement:** macOS 10.15 (Catalina)
- Update to the latest macOS version if possible
- Check for system updates: `softwareupdate -l`
- Verify command availability:
  ```bash
  which dns-sd
  which lpstat
  which launchctl
  ```

## Advanced Troubleshooting

### Debug Mode

Enable verbose output for detailed debugging:

```bash
# Run with debug output
sudo bash -x ./airprint_bridge.sh -t
```

### Network Packet Analysis

Use Wireshark or tcpdump to analyze network traffic:

```bash
# Capture Bonjour traffic
sudo tcpdump -i any -n port 5353

# Capture IPP traffic
sudo tcpdump -i any -n port 631
```

### System Log Analysis

Check comprehensive system logs:

```bash
# View all recent logs
sudo log show --last 1h

# Filter for specific processes
sudo log show --predicate 'process == "dns-sd"' --last 1h
```

## Getting Help

If you're still experiencing issues:

1. **Check the logs:**
   ```bash
   sudo ./airprint_bridge.sh -t 2>&1 | tee debug.log
   ```

2. **Gather system information:**
   ```bash
   system_profiler SPSoftwareDataType SPNetworkDataType
   ```

3. **Create a GitHub issue** with:
   - macOS version
   - Error messages
   - Debug log output
   - Steps to reproduce

4. **Join discussions** on [GitHub Discussions](https://github.com/sapireli/AirPrint_Bridge/discussions)

## Prevention Tips

- **Regular testing:** Test AirPrint functionality weekly
- **Backup configuration:** Keep a copy of working configurations
- **Monitor logs:** Check logs periodically for issues
- **Update regularly:** Keep macOS and AirPrint Bridge updated
- **Document changes:** Note any system changes that might affect printing

---

**Still having issues?** Check out our [Installation Guide](/docs/installation) or [Advanced Configuration](/docs/advanced-configuration) for more detailed information. 