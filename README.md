# blockx

A simple bash script to block distracting websites on macOS and Linux by modifying the system hosts file. Perfect for maintaining focus and productivity by blocking social media and other time-wasting sites.

## Features

- **Instant blocking**: Blocks access to predefined distracting websites
- **Temporary unblock**: Allows temporary access with automatic re-blocking
- **Cross-platform**: Works on macOS and Linux
- **DNS cache flushing**: Automatically clears DNS cache for immediate effect
- **Backup system**: Creates backup of original hosts file for safe restoration
- **Chrome integration**: Opens Chrome's DNS settings for manual cache clearing

## Blocked Sites

The script blocks the following websites by default:
- Facebook (facebook.com, www.facebook.com)
- Twitter/X (twitter.com, x.com, www.twitter.com, www.x.com)
- Instagram (instagram.com, www.instagram.com)
- Reddit (reddit.com, www.reddit.com)
- YouTube (youtube.com, www.youtube.com)
- TikTok (tiktok.com, www.tiktok.com)

## Installation

1. Clone or download the script:
   ```bash
   git clone <repository-url>
   cd blockx
   ```

2. Make the script executable:
   ```bash
   chmod +x blockx.sh
   ```

## Usage

### Block Sites
To block all configured websites:
```bash
sudo ./blockx.sh
```

**Note**: Root privileges are required to modify the system hosts file.

### Temporary Unblock
To temporarily unblock sites for a specified duration (default: 10 minutes):
```bash
sudo ./blockx.sh --temp-unblock [minutes]
```

Examples:
```bash
# Unblock for 10 minutes (default)
sudo ./blockx.sh --temp-unblock

# Unblock for 30 minutes
sudo ./blockx.sh --temp-unblock 30

# Unblock for 1 hour
sudo ./blockx.sh --temp-unblock 60
```

During temporary unblock, sites will be automatically re-blocked after the specified time period.

## How It Works

1. **Backup**: Creates a backup of your current `/etc/hosts` file
2. **Block**: Adds entries to redirect blocked sites to `127.0.0.1` (localhost)
3. **DNS Flush**: Clears system DNS cache for immediate effect
4. **Restore**: For temporary unblock, restores from backup and re-blocks after timeout

## Requirements

- macOS or Linux
- Root/sudo access
- Bash shell

## Platform-Specific Notes

### macOS
- Uses `killall -HUP mDNSResponder` to flush DNS cache
- Opens Chrome's DNS settings automatically

### Linux
- Uses `systemd-resolve --flush-caches` to flush DNS cache
- Attempts to open Chrome/Chromium DNS settings

## Files Created

- `/etc/hosts.backup`: Backup of original hosts file
- `/etc/hosts`: Modified with blocked site entries

## Customization

To block additional sites, edit the `SITES` array in `blockx.sh`:

```bash
SITES=(
    "www.facebook.com"
    "facebook.com"
    # Add your sites here
    "example.com"
    "www.example.com"
)
```

## Troubleshooting

### Sites Still Accessible
1. Try clearing browser cache manually
2. Open Chrome and navigate to `chrome://net-internals/#dns`
3. Click "Clear host cache"
4. Restart your browser

### Permission Denied
Make sure to run the script with `sudo`:
```bash
sudo ./blockx.sh
```

### Backup File Missing
If you see "No backup file found", run the normal blocking command first:
```bash
sudo ./blockx.sh
```

## Safety

- The script creates a backup before making changes
- Original hosts file can be restored from `/etc/hosts.backup`
- Only adds entries, doesn't remove existing ones (except during restore)

## Contributing

Feel free to submit issues and enhancement requests. To add new sites or improve functionality, please submit a pull request.

## License

This project is open source and available under the MIT License.