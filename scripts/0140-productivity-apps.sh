#!/bin/bash

# Productivity Applications Installation Script for Manjaro Linux
# This script installs GUI applications for productivity and development

set -e

# Check if yay is available
if ! command -v yay &> /dev/null; then
    echo "Error: yay is not installed. Please run 00990-yay-install.sh first."
    exit 1
fi

echo "====================================="
echo "  Productivity Apps Installation"
echo "  For Manjaro Linux"
echo "====================================="
echo ""

echo "Installing productivity applications..."
yay -S --needed --noconfirm \
    copyq \
    google-chrome \
    slack-desktop \
    zoom \
    dropbox \
    wezterm \
    unarchiver \
    vlc \
    pinta \
    peek

echo ""
echo "Installing development applications from AUR..."
yay -S --needed --noconfirm \
    cursor-bin \
    hyper-bin \
    jetbrains-toolbox \
    genymotion \
    onedrive-abraunegg \
    arduino-ide-bin \
    arduino-language-server

echo ""
echo "Productivity applications installation completed successfully!"
echo "====================================="
