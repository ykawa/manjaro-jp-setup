#!/bin/bash

# Productivity Applications Installation Script for Manjaro Linux
# This script installs GUI applications for productivity and development
# Skips Android emulator installation in virtual environments

set -e

# Load virtual environment detection library
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
if [ -f "$SCRIPT_DIR/../lib/virt-detect.sh" ]; then
    source "$SCRIPT_DIR/../lib/virt-detect.sh"
else
    echo "Warning: Virtual environment detection library not found"
    # Fallback simple detection
    is_virtual_environment() {
        if command -v systemd-detect-virt > /dev/null 2>&1; then
            [ "$(systemd-detect-virt)" != "none" ]
        else
            return 1
        fi
    }
fi

# Check if yay is available
if ! command -v yay &> /dev/null; then
    echo "Error: yay is not installed. Please run 0090-yay-install.sh first."
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

# Build package list based on environment
DEVELOPMENT_PACKAGES=(
    cursor-bin
    hyper-bin
    jetbrains-toolbox
    onedrive-abraunegg
    arduino-ide-bin
    arduino-language-server
)

# Add Android emulator only on physical hardware
if ! is_virtual_environment; then
    echo "✓ Physical hardware detected - including Android emulator (Genymotion)"
    DEVELOPMENT_PACKAGES+=(genymotion)
else
    echo "🔍 Virtual environment detected - skipping Android emulator (Genymotion)"
    echo "   (Android emulators typically don't work well in nested virtualization)"
fi

# Install the packages
yay -S --needed --noconfirm "${DEVELOPMENT_PACKAGES[@]}"

echo ""
echo "Productivity applications installation completed successfully!"
echo "====================================="
