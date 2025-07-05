#!/bin/bash

# Vim Installation Script for Manjaro Linux
# This script installs vim and python-pynvim for enhanced functionality
# Requires yay to be installed first

set -e

echo "================================"
echo "  Vim Installation Script"
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

# Check if vim is already installed and up to date
if command -v vim &> /dev/null; then
    echo "Vim is already installed:"
    vim --version | head -1
    echo ""
    echo "Checking for updates and ensuring python-pynvim is installed..."
else
    echo "Installing vim and related packages..."
fi

# Install vim and python-pynvim
echo "Installing/updating vim and python-pynvim..."
yay -S --needed --noconfirm \
    vim \
    python-pynvim

echo ""
echo "Verifying installations..."

# Verify vim installation
if command -v vim &> /dev/null; then
    echo "✓ Vim installed successfully:"
    vim --version | head -1
else
    echo "✗ Vim installation failed"
    exit 1
fi

# Verify python-pynvim installation
if python -c "import pynvim" 2>/dev/null; then
    echo "✓ python-pynvim installed successfully"
else
    echo "✗ python-pynvim installation failed or not accessible"
    exit 1
fi

echo ""
echo "Vim installation and setup completed successfully!"
echo ""
echo "IMPORTANT:"
echo "- Vim is now installed with python-pynvim support"
echo "- You can further customize vim by editing ~/.vimrc"
echo "================================"
