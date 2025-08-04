#!/bin/bash

# Restore Update Notifier After Setup
# This script re-enables update notifiers that were disabled during setup

set -e

echo "================================"
echo "  Restore Update Notifier"
echo "  After Setup Completion"
echo "================================"
echo ""

# Backup directory
BACKUP_DIR="/tmp/manjaro-setup-notifier-backup"

if [ ! -d "$BACKUP_DIR" ]; then
    echo "⚠ No backup directory found. Update notifiers may not have been disabled."
    echo "Attempting to re-enable common update notifiers anyway..."
    echo ""
fi

echo "Restoring update notifier autostart entries..."

if [ -d "$BACKUP_DIR" ]; then
    # Restore backed up desktop files
    for backup_file in "$BACKUP_DIR"/*.desktop; do
        if [ -f "$backup_file" ]; then
            filename=$(basename "$backup_file")
            echo "  Restoring: $filename"

            # Find where to restore it
            for dir in "/etc/xdg/autostart" "$HOME/.config/autostart" "/usr/share/applications"; do
                if [ -f "$dir/$filename" ]; then
                    # Remove the Hidden=true line we added
                    if [ -w "$dir/$filename" ]; then
                        sed -i '/^Hidden=true$/d' "$dir/$filename"
                    else
                        sudo sed -i '/^Hidden=true$/d' "$dir/$filename" 2>/dev/null || true
                    fi
                    echo "    Restored to: $dir/$filename"
                    break
                fi
            done
        fi
    done
fi

# Re-enable systemd services
echo "Re-enabling update notifier systemd services..."

if [ -f "$BACKUP_DIR/enabled_services.backup" ]; then
    while read -r line; do
        service=$(echo "$line" | awk '{print $1}')
        if [[ "$service" =~ ^(pamac|update|software) ]]; then
            echo "  Re-enabling service: $service"
            sudo systemctl enable "$service" || true
        fi
    done < "$BACKUP_DIR/enabled_services.backup"
else
    # Re-enable common services
    UPDATE_SERVICES=(
        "pamac.service"
        "pamac-daemon.service"
        "packagekit.service"
    )

    for service in "${UPDATE_SERVICES[@]}"; do
        if systemctl list-unit-files "$service" &>/dev/null; then
            echo "  Re-enabling service: $service"
            sudo systemctl enable "$service" || true
        fi
    done
fi

echo ""
echo "Starting update notifier services..."

# Start pamac daemon if available
if systemctl list-unit-files "pamac-daemon.service" &>/dev/null; then
    echo "  Starting pamac daemon..."
    sudo systemctl start pamac-daemon.service || true
fi

# Start packagekit if available
if systemctl list-unit-files "packagekit.service" &>/dev/null; then
    echo "  Starting packagekit..."
    sudo systemctl start packagekit.service || true
fi

echo ""
echo "Cleaning up backup directory..."
if [ -d "$BACKUP_DIR" ]; then
    rm -rf "$BACKUP_DIR"
    echo "✓ Backup directory cleaned up"
fi

echo ""
echo "================================"
echo "  Update Notifier Restored"
echo "================================"
echo ""
echo "✓ Update notifiers have been re-enabled"
echo "✓ System update notifications will resume"
echo "✓ Setup cleanup completed"
echo ""
echo "Note: You may need to log out and back in for all changes to take effect."
echo ""
