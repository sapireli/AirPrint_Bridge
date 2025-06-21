---
sidebar_position: 6
---

# ⚙️ Advanced Configuration

Advanced configuration options and customization for AirPrint Bridge power users.

## Custom Script Location

By default, AirPrint Bridge creates the registration script in the current directory and copies it to `/usr/local/bin` during installation. You can specify a custom location:

```bash
# Test with custom script location
sudo ./airprint_bridge.sh -t -f /path/to/custom_launcher.sh

# Install with custom script location
sudo ./airprint_bridge.sh -i -f /path/to/custom_launcher.sh
```

**Use cases:**
- **Network storage**: Store scripts on a network drive
- **Custom organization**: Organize scripts in specific directories
- **Backup purposes**: Keep scripts in backup locations

## Logging Configuration

### Enable Verbose Logging

To enable detailed logging for debugging:

1. **Edit the script**:
   ```bash
   # Open in text editor
   nano airprint_bridge.sh
   
   # Or use sed to change automatically
   sed -i '' 's/LOGGING=0/LOGGING=1/' airprint_bridge.sh
   ```

2. **Find the logging variable**:
   ```bash
   # Look for this line in the script
   LOGGING=0
   ```

3. **Change to enable logging**:
   ```bash
   LOGGING=1
   ```

4. **Reinstall the service**:
   ```bash
   sudo ./airprint_bridge.sh -u
   sudo ./airprint_bridge.sh -i
   ```

### Log File Management

With logging enabled, logs are written to `airprint_bridge.log` in the script's directory:

```bash
# View logs in real-time
tail -f airprint_bridge.log

# View recent logs
tail -n 50 airprint_bridge.log

# Search logs for specific terms
grep "ERROR" airprint_bridge.log
grep "WARNING" airprint_bridge.log

# Archive old logs
mv airprint_bridge.log airprint_bridge.log.$(date +%Y%m%d)
```

### Log Rotation

To prevent log files from growing too large:

```bash
# Create a log rotation script
cat > /usr/local/bin/rotate_airprint_logs.sh << 'EOF'
#!/bin/bash
LOG_FILE="/path/to/airprint_bridge.log"
MAX_SIZE="10M"

if [ -f "$LOG_FILE" ]; then
    SIZE=$(du -h "$LOG_FILE" | cut -f1)
    if [ "$SIZE" -gt "$MAX_SIZE" ]; then
        mv "$LOG_FILE" "${LOG_FILE}.$(date +%Y%m%d_%H%M%S)"
        touch "$LOG_FILE"
    fi
fi
EOF

chmod +x /usr/local/bin/rotate_airprint_logs.sh

# Add to crontab for daily rotation
echo "0 2 * * * /usr/local/bin/rotate_airprint_logs.sh" | sudo crontab -
```

## Firewall Configuration

### Manual Firewall Setup

If automatic firewall configuration fails, manually configure:

1. **Open System Settings > Network > Firewall**
2. **Click "Firewall Options"**
3. **Add applications**:
   - `/usr/bin/dns-sd`
   - `/usr/sbin/cupsd`
4. **Allow incoming connections** for these services

### Advanced Firewall Rules

For more granular control, use `pfctl`:

```bash
# Create custom firewall rules
sudo tee /etc/pf.airprint.conf << 'EOF'
# AirPrint Bridge firewall rules
table <airprint_services> persist { 5353, 631, 9100 }

# Allow AirPrint services
pass in proto tcp from any to any port <airprint_services>
pass in proto udp from any to any port <airprint_services>

# Allow Bonjour/mDNS
pass in proto udp from any to any port 5353
EOF

# Load rules (requires SIP to be disabled)
sudo pfctl -f /etc/pf.airprint.conf
```

## CUPS Configuration

### Custom CUPS Settings

AirPrint Bridge automatically configures CUPS, but you can customize:

```bash
# Backup current CUPS configuration
sudo cp /etc/cups/cupsd.conf /etc/cups/cupsd.conf.backup

# Edit CUPS configuration
sudo nano /etc/cups/cupsd.conf
```

**Key settings to modify:**
```conf
# Allow remote connections
Listen *:631

# Enable sharing
<Location />
  Order allow,deny
  Allow all
</Location>

# Enable printer sharing
<Location /printers>
  Order allow,deny
  Allow all
</Location>
```

### CUPS Logging

Enable detailed CUPS logging:

```bash
# Edit CUPS configuration
sudo nano /etc/cups/cupsd.conf

# Add or modify logging
LogLevel debug
LogTimeFormat usecs
```

## Network Configuration

### Multicast Settings

Ensure multicast traffic is properly configured:

```bash
# Check multicast routing
netstat -rn | grep 224.0.0.0

# Enable multicast routing (if needed)
sudo route add -net 224.0.0.0/4 -interface lo0
```

### Network Interface Priority

If you have multiple network interfaces, prioritize the correct one:

```bash
# List network interfaces
ifconfig | grep inet

# Set interface priority in script
# Edit airprint_bridge.sh and modify the interface selection
```

## Performance Optimization

### Resource Usage

Monitor resource usage:

```bash
# Check CPU and memory usage
top -pid $(pgrep dns-sd)

# Monitor network connections
lsof -i :5353
lsof -i :631

# Check disk I/O
iostat 1
```

### Optimization Tips

1. **Reduce logging verbosity** in production
2. **Use SSD storage** for better performance
3. **Limit concurrent connections** if needed
4. **Monitor system resources** regularly

## Security Considerations

### Access Control

Restrict access to AirPrint services:

```bash
# Create access control lists
sudo tee /etc/airprint_access.conf << 'EOF'
# Allow specific IP ranges
ALLOW_IPS="192.168.1.0/24 10.0.0.0/8"

# Block specific IPs
BLOCK_IPS="192.168.1.100"
EOF
```

### Service Hardening

Harden the AirPrint Bridge service:

```bash
# Create a dedicated user for AirPrint Bridge
sudo dscl . -create /Users/airprint
sudo dscl . -create /Users/airprint UserShell /bin/bash
sudo dscl . -create /Users/airprint RealName "AirPrint Bridge"
sudo dscl . -create /Users/airprint UniqueID 501
sudo dscl . -create /Users/airprint PrimaryGroupID 20

# Modify the launchd plist to run as this user
sudo nano /Library/LaunchDaemons/com.airprint.bridge.plist
```

## Backup and Recovery

### Configuration Backup

Create regular backups of your configuration:

```bash
# Create backup script
cat > /usr/local/bin/backup_airprint_config.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/Users/$(whoami)/Documents/AirPrint_Backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

# Backup script
cp airprint_bridge.sh "$BACKUP_DIR/airprint_bridge_$DATE.sh"

# Backup launchd plist
sudo cp /Library/LaunchDaemons/com.airprint.bridge.plist "$BACKUP_DIR/"

# Backup logs
cp airprint_bridge.log "$BACKUP_DIR/airprint_bridge_$DATE.log" 2>/dev/null || true

echo "Backup completed: $BACKUP_DIR"
EOF

chmod +x /usr/local/bin/backup_airprint_config.sh
```

### Recovery Procedures

**Restore from backup:**
```bash
# Stop the service
sudo ./airprint_bridge.sh -u

# Restore files
sudo cp /path/to/backup/com.airprint.bridge.plist /Library/LaunchDaemons/
cp /path/to/backup/airprint_bridge.sh ./

# Restart the service
sudo ./airprint_bridge.sh -i
```

## Monitoring and Alerting

### Health Checks

Create automated health checks:

```bash
# Create health check script
cat > /usr/local/bin/check_airprint_health.sh << 'EOF'
#!/bin/bash

# Check if service is running
if ! sudo launchctl list | grep -q airprint; then
    echo "ERROR: AirPrint Bridge service not running"
    exit 1
fi

# Check if dns-sd processes are active
if ! pgrep -f "dns-sd.*_ipp._tcp" > /dev/null; then
    echo "ERROR: No dns-sd processes found"
    exit 1
fi

# Check network connectivity
if ! ping -c 1 224.0.0.251 > /dev/null 2>&1; then
    echo "WARNING: Multicast connectivity issues"
fi

echo "AirPrint Bridge is healthy"
EOF

chmod +x /usr/local/bin/check_airprint_health.sh
```

### Automated Monitoring

Set up automated monitoring:

```bash
# Add to crontab for hourly checks
echo "0 * * * * /usr/local/bin/check_airprint_health.sh" | sudo crontab -

# Or use launchd for more sophisticated scheduling
sudo tee /Library/LaunchDaemons/com.airprint.healthcheck.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.airprint.healthcheck</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/check_airprint_health.sh</string>
    </array>
    <key>StartInterval</key>
    <integer>3600</integer>
    <key>StandardOutPath</key>
    <string>/var/log/airprint_health.log</string>
    <key>StandardErrorPath</key>
    <string>/var/log/airprint_health_error.log</string>
</dict>
</plist>
EOF

sudo launchctl load /Library/LaunchDaemons/com.airprint.healthcheck.plist
```

## Troubleshooting Advanced Issues

### Debug Mode

Enable comprehensive debugging:

```bash
# Run with debug output
sudo bash -x ./airprint_bridge.sh -t

# Enable shell debugging
set -x
sudo ./airprint_bridge.sh -t
set +x
```

### Network Analysis

Analyze network traffic:

```bash
# Capture Bonjour traffic
sudo tcpdump -i any -n port 5353 -w bonjour.pcap

# Capture IPP traffic
sudo tcpdump -i any -n port 631 -w ipp.pcap

# Analyze with Wireshark
open bonjour.pcap
```

### System Log Analysis

Comprehensive log analysis:

```bash
# View all system logs
sudo log show --last 1h | grep -i airprint

# Filter for specific processes
sudo log show --predicate 'process == "dns-sd"' --last 1h

# Export logs for analysis
sudo log show --last 24h > system_logs.txt
```

---

**Need help with advanced configuration?** Check out our [Troubleshooting Guide](/docs/troubleshooting) or [join the discussions](https://github.com/sapireli/AirPrint_Bridge/discussions). 