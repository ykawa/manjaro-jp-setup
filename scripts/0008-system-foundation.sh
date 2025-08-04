#!/bin/bash

# System Foundation Setup Script for Manjaro Linux
# This script performs essential system setup that should run before everything else

set -e

echo "================================"
echo "  System Foundation Setup"
echo "  Essential System Configuration"
echo "================================"
echo ""

# Check for pacman lock first
LOCK_FILE="/var/lib/pacman/db.lck"
if [ -f "$LOCK_FILE" ]; then
    echo "⚠ Pacman database is locked. Attempting to resolve..."

    # Check if any package manager is running
    if pgrep -f "pacman\|yay\|pamac" > /dev/null; then
        echo "✗ Package manager is currently running. Waiting for it to complete..."
        # Wait up to 30 seconds for package manager to finish
        for i in {1..30}; do
            if ! pgrep -f "pacman\|yay\|pamac" > /dev/null; then
                echo "✓ Package manager finished"
                break
            fi
            echo "  Waiting... ($i/30)"
            sleep 1
        done

        # If still running after 30 seconds, exit with error
        if pgrep -f "pacman\|yay\|pamac" > /dev/null; then
            echo "✗ Package manager still running after 30 seconds. Please stop it manually."
            exit 1
        fi
    else
        echo "No package manager running. Removing stale lock file..."
        sudo rm -f "$LOCK_FILE" || {
            echo "✗ Failed to remove lock file"
            exit 1
        }
        echo "✓ Lock file removed"
    fi
fi

echo "Setting up Japanese mirrors..."
sudo pacman-mirrors -c Japan
echo "✓ Japanese mirrors configured"

echo ""
echo "Updating archlinux-keyring (essential for package verification)..."
if sudo pacman -S --noconfirm archlinux-keyring; then
    echo "✓ archlinux-keyring updated successfully"
else
    echo "⚠ Failed to update archlinux-keyring, continuing anyway..."
fi

echo ""
echo "Updating package database..."
sudo pacman -Sy
echo "✓ Package database updated"

echo ""
echo "================================"
echo "  System Foundation Complete"
echo "================================"
echo ""
echo "✓ Japanese mirrors configured"
echo "✓ Package keyring updated"
echo "✓ Package database synchronized"
echo "✓ System ready for package installations"
echo ""
