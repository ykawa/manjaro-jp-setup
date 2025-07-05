#!/bin/bash

# Terminal Utilities Installation Script for Manjaro Linux
# This script installs modern terminal utilities and visual tools

set -e

# Check if yay is available
if ! command -v yay &> /dev/null; then
    echo "Error: yay is not installed. Please run 00990-yay-install.sh first."
    exit 1
fi

echo "====================================="
echo "  Terminal Utilities Installation"
echo "  For Manjaro Linux"
echo "====================================="
echo ""

echo "Installing terminal utilities..."
yay -S --needed --noconfirm \
    cfonts \
    vivid \
    pastel \
    teetty \
    hexyl \
    duplink \
    fclones \
    lsd

echo ""
echo "Terminal utilities installation completed successfully!"
echo "====================================="
