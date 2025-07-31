#!/bin/bash

# System Update Script for Manjaro Linux
# This script updates the system packages and package database

set -e

echo "================================"
echo "  System Update Script"
echo "  For Manjaro Linux"
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

echo "Upgrading system packages..."
sudo pacman -Su --noconfirm

echo ""
echo "Cleaning package cache..."
sudo pacman -Sc --noconfirm

echo ""
echo "Final system synchronization..."
sudo pacman -Syu --noconfirm

echo ""
echo "System update completed successfully!"
echo "================================"
