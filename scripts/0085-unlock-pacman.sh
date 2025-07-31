#!/bin/bash

# Unlock Pacman Database Script
# This script removes pacman lock file if it exists and no package manager is running

set -e

echo "================================"
echo "  Unlock Pacman Database"
echo "  For Manjaro Linux"
echo "================================"
echo ""

LOCK_FILE="/var/lib/pacman/db.lck"

# First, kill any update notifiers that might be causing conflicts
echo "Stopping update notifiers and package managers..."

# Kill update notifiers first
if pgrep -f "pamac.*notifier|update.*notifier|software.*updater" > /dev/null; then
    echo "  Stopping update notifier processes..."
    sudo pkill -f "pamac.*notifier|update.*notifier|software.*updater" || true
    sleep 2
fi

# Kill any running package managers
if pgrep -f "pacman\|yay\|pamac" > /dev/null; then
    echo "  Stopping package manager processes..."
    echo "  Running processes:"
    pgrep -f "pacman\|yay\|pamac" -l
    sudo pkill -f "pacman\|yay\|pamac" || true
    sleep 3

    # Force kill if still running
    if pgrep -f "pacman\|yay\|pamac" > /dev/null; then
        echo "  Force killing remaining processes..."
        sudo pkill -9 -f "pacman\|yay\|pamac" || true
        sleep 2
    fi
fi

echo "Checking pacman database lock status..."

# Check if lock file exists
if [ -f "$LOCK_FILE" ]; then
    echo "⚠ Pacman lock file found: $LOCK_FILE"

    # After killing processes, remove the lock file
    echo "Removing pacman lock file..."
    if sudo rm -f "$LOCK_FILE"; then
        echo "✓ Pacman lock file removed successfully"
    else
        echo "✗ Failed to remove lock file. Please run with sudo privileges."
        exit 1
    fi
else
    echo "✓ No pacman lock file found. Database is not locked."
fi

# Double-check no package managers are running
if pgrep -f "pacman\|yay\|pamac" > /dev/null; then
    echo "⚠ Warning: Package manager processes are still running:"
    pgrep -f "pacman\|yay\|pamac" -l
    echo "You may need to manually stop these processes."
fi

echo ""
echo "Testing pacman database access..."
if sudo pacman -Sy > /dev/null 2>&1; then
    echo "✓ Pacman database is accessible and updated"
else
    echo "✗ Still having issues with pacman database"
    echo "You may need to:"
    echo "1. Check disk space: df -h"
    echo "2. Check permissions: ls -la /var/lib/pacman/"
    echo "3. Restart the system if issues persist"
    exit 1
fi

echo ""
echo "================================"
echo "  Pacman Database Unlocked"
echo "================================"
echo ""
echo "✓ Pacman database is now accessible"
echo "✓ Package installations can proceed"
echo ""
