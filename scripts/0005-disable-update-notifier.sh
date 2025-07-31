#!/bin/bash

# Disable Update Notifier During Setup
# This script disables automatic update notifiers to prevent package manager conflicts during setup

set -e

echo "================================"
echo "  Disable Update Notifier"
echo "  For Setup Process"
echo "================================"
echo ""

# Backup directory
BACKUP_DIR="/tmp/manjaro-setup-notifier-backup"
mkdir -p "$BACKUP_DIR"

echo "Disabling update notifiers to prevent package manager conflicts..."

# Kill running update notifiers
echo "Stopping running update notifier processes..."
if pgrep -f "pamac.*notifier" > /dev/null; then
    echo "✓ Killing pamac notifier processes"
    sudo pkill -f "pamac.*notifier" || true
fi

if pgrep -f "update.*notifier" > /dev/null; then
    echo "✓ Killing update notifier processes"
    sudo pkill -f "update.*notifier" || true
fi

if pgrep -f "software.*updater" > /dev/null; then
    echo "✓ Killing software updater processes"
    sudo pkill -f "software.*updater" || true
fi

# Disable autostart entries
echo "Disabling update notifier autostart entries..."

AUTOSTART_DIRS=(
    "/etc/xdg/autostart"
    "$HOME/.config/autostart"
    "/usr/share/applications"
)

UPDATE_NOTIFIER_FILES=(
    "pamac-tray.desktop"
    "update-notifier.desktop"
    "software-updater.desktop"
    "manjaro-hello.desktop"
    "gnome-software-service.desktop"
)

for dir in "${AUTOSTART_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        for file in "${UPDATE_NOTIFIER_FILES[@]}"; do
            if [ -f "$dir/$file" ]; then
                echo "  Backing up: $dir/$file"
                cp "$dir/$file" "$BACKUP_DIR/" 2>/dev/null || true

                # Create disabled version
                echo "  Disabling: $dir/$file"
                if [ -w "$dir/$file" ]; then
                    echo "Hidden=true" >> "$dir/$file"
                else
                    sudo bash -c "echo 'Hidden=true' >> '$dir/$file'" 2>/dev/null || true
                fi
            fi
        done
    fi
done

# Disable systemd services
echo "Disabling update notifier systemd services..."

UPDATE_SERVICES=(
    "pamac.service"
    "pamac-daemon.service"
    "packagekit.service"
    "software-updater.service"
)

for service in "${UPDATE_SERVICES[@]}"; do
    if systemctl is-enabled "$service" &>/dev/null; then
        echo "  Disabling service: $service"
        sudo systemctl disable "$service" || true
        sudo systemctl stop "$service" || true
    fi
done

# Create backup of enabled services
systemctl list-unit-files --state=enabled | grep -E "(pamac|update|software)" > "$BACKUP_DIR/enabled_services.backup" 2>/dev/null || true

echo ""
echo "Waiting 5 seconds for processes to fully terminate..."
sleep 5

echo ""
echo "Verifying no package managers are running..."
if pgrep -f "pacman|yay|pamac" > /dev/null; then
    echo "⚠ Some package manager processes are still running:"
    pgrep -f "pacman|yay|pamac" -l
    echo "Attempting to force kill..."
    sudo pkill -9 -f "pacman|yay|pamac" || true
    sleep 2
fi

if ! pgrep -f "pacman|yay|pamac" > /dev/null; then
    echo "✓ No package manager processes running"
else
    echo "⚠ Warning: Some package manager processes may still be running"
fi

echo ""
echo "================================"
echo "  Update Notifier Disabled"
echo "================================"
echo ""
echo "✓ Update notifiers have been disabled for setup"
echo "✓ Backup saved to: $BACKUP_DIR"
echo "✓ Package manager conflicts should be prevented"
echo ""
