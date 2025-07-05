#!/bin/bash

# Sudo Setup Script for Manjaro Linux
# This script configures sudo to work without password for the current user

set -e

echo "================================"
echo "  Sudo Setup Script"
echo "  For Manjaro Linux"
echo "================================"
echo ""

# Get current user
CURRENT_USER=$(whoami)
echo "Current user: $CURRENT_USER"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "ERROR: This script should not be run as root."
    echo "Please run as a regular user with sudo privileges."
    exit 1
fi

echo "Configuring sudo without password for user: $CURRENT_USER"
echo ""

# Check if user is in wheel group
if groups "$CURRENT_USER" | grep -q "\bwheel\b"; then
    echo "✓ User $CURRENT_USER is already in wheel group"
else
    echo "Adding user $CURRENT_USER to wheel group..."
    sudo usermod -aG wheel "$CURRENT_USER"
    echo "✓ User added to wheel group"
fi

# Create sudoers file for the current user
SUDOERS_FILE="/etc/sudoers.d/99-$CURRENT_USER-nopasswd"

echo "Creating sudoers configuration..."
echo "This will require your current password one last time."

# Create the sudoers entry with explicit specification
echo "$CURRENT_USER ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee "$SUDOERS_FILE" > /dev/null

# Also ensure wheel group has passwordless sudo
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee -a "$SUDOERS_FILE" > /dev/null

sudo chmod 440 "$SUDOERS_FILE"

echo ""
echo "Sudo setup completed successfully!"
echo ""
echo "IMPORTANT:"
echo "- Sudo will no longer require a password for user: $CURRENT_USER"
echo "- This change takes effect immediately"
echo "- Configuration stored in: $SUDOERS_FILE"
echo "================================"
