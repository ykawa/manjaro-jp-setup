#!/bin/bash

# Fonts Installation Script for Manjaro Linux
# This script installs essential fonts for development and Japanese support
# Requires yay to be installed first

set -e

echo "================================"
echo "  Fonts Installation Script"
echo "  For Manjaro Linux"
echo "================================"
echo ""

# Check if yay is available
if ! command -v yay &> /dev/null; then
    echo "Error: yay is not installed. Please run 0015-yay-install.sh first."
    exit 1
fi

# Get current user
CURRENT_USER=$(whoami)
echo "Current user: $CURRENT_USER"
echo ""

# List of fonts to install
# FONTS=(
#     "adobe-source-code-pro-fonts"
#     "adobe-source-han-sans-jp-fonts"
#     "adobe-source-han-serif-otc-fonts"
#     "otf-source-han-code-jp"
#     "ttf-cica"
#     "ttf-font-awesome"
#     "ttf-jetbrains-mono"
#     "ttf-jetbrains-mono-nerd"
#     "ttf-ms-win11-auto-japanese"
# )
# List of fonts to install
FONTS=(
    "adobe-source-code-pro-fonts"
    "adobe-source-han-sans-jp-fonts"
    "adobe-source-han-serif-otc-fonts"
    "noto-fonts-emoji"
    "otf-source-han-code-jp"
    "ttf-cica"
    "ttf-font-awesome"
    "ttf-jetbrains-mono"
    "ttf-jetbrains-mono-nerd"
)

echo "Checking and installing fonts..."
echo ""

# Check which fonts are already installed
FONTS_TO_INSTALL=()
for font in "${FONTS[@]}"; do
    if pacman -Qi "$font" &>/dev/null; then
        echo "✓ $font: already installed"
    else
        echo "- $font: needs installation"
        FONTS_TO_INSTALL+=("$font")
    fi
done

echo ""

# Install missing fonts
if [ ${#FONTS_TO_INSTALL[@]} -eq 0 ]; then
    echo "✓ All fonts are already installed!"
else
    echo "Installing ${#FONTS_TO_INSTALL[@]} fonts..."
    echo "Fonts to install: ${FONTS_TO_INSTALL[*]}"
    echo ""

    # Install fonts using yay with --needed flag for idempotency
    yay -S --needed --noconfirm "${FONTS_TO_INSTALL[@]}"

    echo ""
    echo "✓ Font installation completed"
fi

echo ""
echo "Refreshing font cache..."
fc-cache -fv

echo ""
echo "Verifying font installation..."
echo ""

# Verify installations
FAILED_FONTS=()
for font in "${FONTS[@]}"; do
    if pacman -Qi "$font" &>/dev/null; then
        echo "✓ $font: verified"
    else
        echo "✗ $font: installation failed"
        FAILED_FONTS+=("$font")
    fi
done

echo ""

if [ ${#FAILED_FONTS[@]} -eq 0 ]; then
    echo "✓ All fonts installed and verified successfully!"
else
    echo "⚠ Some fonts failed to install: ${FAILED_FONTS[*]}"
    echo "You may need to install them manually or check AUR availability."
fi

echo ""
echo "Font installation completed!"
echo ""
echo "INSTALLED FONTS:"
echo "- Adobe Source Code Pro (programming font)"
echo "- Adobe Source Han Sans JP (Japanese sans-serif)"
echo "- Adobe Source Han Serif (Japanese serif)"
echo "- Source Han Code JP (Japanese monospace)"
echo "- Cica (programming font with Japanese support)"
echo "- Font Awesome (icon font)"
echo "- JetBrains Mono (programming font)"
echo "- JetBrains Mono Nerd (programming font with icons)"
echo ""
echo "USAGE:"
echo "- Fonts are now available system-wide"
echo "- Use 'fc-list' to see all available fonts"
echo "- Configure your terminal/editor to use preferred fonts"
echo "- Recommended programming fonts: JetBrains Mono, Source Code Pro, Cica"
echo "================================"
