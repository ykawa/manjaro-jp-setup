#!/bin/bash

# Boot Script for Manjaro Japanese Setup
# Downloads and runs the manjaro-jp-setup repository

set -e

REPO_URL="https://github.com/ykawa/manjaro-jp-setup.git"
INSTALL_DIR="$HOME/.local/share/manjaro-jp-setup"
SCRIPT_NAME="manjaro-jp-setup"

echo "================================"
echo "  Manjaro Japanese Setup Boot"
echo "================================"
echo ""

# Check if git is available
if ! command -v git &> /dev/null; then
    echo "Error: git is required but not installed."
    echo "Please install git first: sudo pacman -S git"
    exit 1
fi

# Create parent directory if it doesn't exist
mkdir -p "$(dirname "$INSTALL_DIR")"

# Remove existing installation if it exists
if [ -d "$INSTALL_DIR" ]; then
    echo "Removing existing installation..."
    rm -rf "$INSTALL_DIR"
fi

# Clone the repository
echo "Downloading manjaro-jp-setup..."
if git clone "$REPO_URL" "$INSTALL_DIR"; then
    echo "✓ Repository downloaded successfully"
else
    echo "✗ Failed to download repository"
    exit 1
fi

echo ""
echo "Repository installed to: $INSTALL_DIR"
echo ""

# Change to the installation directory
cd "$INSTALL_DIR"

# Make scripts executable
echo "Setting up permissions..."
chmod +x setup.sh verify-setup.sh
find scripts -name "*.sh" -exec chmod +x {} \;

echo ""
echo "Starting setup process..."
echo "================================"
echo ""

# Run the main setup script
exec ./setup.sh
