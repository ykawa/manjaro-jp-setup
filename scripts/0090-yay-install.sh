#!/bin/bash

# Yay (AUR helper) Installation Script for Manjaro Linux
# This script installs yay for accessing Arch User Repository packages

set -e

echo "================================"
echo "  Yay Installation Script"
echo "  AUR Helper for Manjaro Linux"
echo "================================"
echo ""

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
