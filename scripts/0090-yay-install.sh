#!/bin/bash

# Yay (AUR helper) Installation Script for Manjaro Linux
# This script installs yay for accessing Arch User Repository packages

set -e

echo "================================"
echo "  Yay Installation Script"
echo "  AUR Helper for Manjaro Linux"
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

# Check if yay is already installed
if command -v yay &> /dev/null; then
    echo "Yay is already installed:"
    yay --version
    echo "Skipping installation."
    echo "================================"
    exit 0
fi

echo "Installing yay using pacman..."

# Install yay using pacman with --needed flag for idempotency
sudo pacman -S --needed --noconfirm yay

echo ""
echo "Verifying yay installation..."
if command -v yay &> /dev/null; then
    echo "✓ Yay installed successfully:"
    yay --version
else
    echo "✗ Yay installation failed"
    exit 1
fi

echo ""
echo "Yay installation completed successfully!"
echo "You can now install AUR packages using: yay -S package-name"
echo "================================"
