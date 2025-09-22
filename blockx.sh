#!/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

# List of websites to block
SITES=(
    "www.facebook.com"
    "facebook.com"
    "www.twitter.com"
    "twitter.com"
    "www.x.com"
    "x.com"
    "www.instagram.com"
    "instagram.com"
    "www.reddit.com"
    "reddit.com"
    "www.youtube.com"
    "youtube.com"
    "tiktok.com"
    "www.tiktok.com"
)

# Hosts file location
HOSTS_FILE="/etc/hosts"

# Function to block sites
block_sites() {
    # Add header for blocked sites
    echo -e "\n# Blocked Sites" >> "$HOSTS_FILE"
    
    # Block each site by redirecting to localhost
    for site in "${SITES[@]}"; do
        if ! grep -q "^127.0.0.1 $site" "$HOSTS_FILE"; then
            echo "127.0.0.1 $site" >> "$HOSTS_FILE"
            echo "Blocking: $site"
        else
            echo "Already blocked: $site"
        fi
    done
}

# Function to unblock sites
unblock_sites() {
    # Restore from backup
    cp "$HOSTS_FILE.backup" "$HOSTS_FILE"
    echo "Sites temporarily unblocked"
}

# Function to flush DNS cache
flush_dns() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        killall -HUP mDNSResponder
        # Open Chrome's DNS settings on macOS
        echo "Flushed DNS cache"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        systemd-resolve --flush-caches || true
        # Open Chrome's DNS settings on Linux
        google-chrome chrome://net-internals/#dns || \
        chromium-browser chrome://net-internals/#dns || \
        chromium chrome://net-internals/#dns
        echo "Flushed DNS cache"
    fi
}

# Function to show usage
show_usage() {
    echo "Usage:"
    echo "  $0                     # Block sites"
    echo "  $0 --temp-unblock [minutes]  # Temporarily unblock sites for specified minutes (default: 10)"
    exit 1
}

# Check command line arguments
if [ "$1" == "--temp-unblock" ]; then
    # Check if backup exists
    if [ ! -f "$HOSTS_FILE.backup" ]; then
        echo "No backup file found. Please run the script normally first."
        exit 1
    fi
    
    # Get duration in minutes, default to 10 if not specified
    DURATION="${2:-10}"
    
    # Validate that duration is a positive number
    if ! [[ "$DURATION" =~ ^[0-9]+$ ]] || [ "$DURATION" -eq 0 ]; then
        echo "Error: Duration must be a positive number of minutes"
        show_usage
    fi
    
    echo ""
    echo "🌱 Before unblocking, let's take a moment to breathe..."
    echo "Take deep breaths and center yourself for $((DURATION * 3)) seconds"
    echo ""

    # Breathing animation proportional to unblock duration
    for ((i=$((DURATION * 3)); i>=1; i--)); do
        if [ $((i % 4)) -eq 0 ]; then
            echo -ne "\r🫁 Breathe in... ($i seconds remaining)   "
        elif [ $((i % 2)) -eq 0 ]; then
            echo -ne "\r💨 Breathe out... ($i seconds remaining)  "
        else
            echo -ne "\r🧘 Center yourself... ($i seconds remaining) "
        fi
        sleep 1
    done

    echo -ne "\r✨ Ready! Temporarily unblocking sites for $DURATION minutes...\n"
    echo ""

    unblock_sites
    flush_dns
    
    # Wait specified minutes and then reblock
    (
        sleep $(($DURATION * 60))  # Convert minutes to seconds
        echo "Reblocking sites..."
        block_sites
        flush_dns
        echo "Sites have been reblocked"
        open -a "Google Chrome" chrome://net-internals/#dns
    ) &
    
    echo "Sites will be automatically reblocked in $DURATION minutes"
    exit 0
fi

# Normal blocking operation
# Backup hosts file
cp "$HOSTS_FILE" "$HOSTS_FILE.backup"
echo "Creating backup of hosts file at $HOSTS_FILE.backup"

block_sites
flush_dns
echo "Websites have been blocked successfully!"
