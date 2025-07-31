#!/bin/bash

# Nodebrew and Node.js Setup Script for Manjaro Linux
# This script installs nodebrew and Node.js stable version

set -e

echo "================================"
echo "  Nodebrew and Node.js Setup"
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
    echo "Please run as a regular user."
    exit 1
fi

echo "Step 1: Installing nodebrew..."

# Check if nodebrew is already installed
if command -v nodebrew &> /dev/null; then
    echo "Nodebrew is already installed:"
    nodebrew -v
    echo ""
else
    echo "Downloading and installing nodebrew..."

    # Download and install nodebrew
    curl -L git.io/nodebrew | perl - setup

    echo "✓ Nodebrew installed successfully"
    echo ""
fi

# Add nodebrew to PATH for this session
export PATH=$HOME/.nodebrew/current/bin:$PATH

echo "Step 2: Configuring PATH for nodebrew..."

# Check if dotfiles management is available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_SCRIPT="$SCRIPT_DIR/../0050-dotfiles-setup.sh"

# Flags to track configuration
BASHRC_UPDATED=false
ZSHRC_UPDATED=false

# Check if dotfiles system is being used
if [ -f "$DOTFILES_SCRIPT" ] && [ -f "$SCRIPT_DIR/../dotfiles/dot.zshrc" ] && [ -f "$SCRIPT_DIR/../dotfiles/dot.bashrc_additions" ]; then
    echo "✓ Nodebrew PATH already configured in dotfiles system"
    echo "  (Configured in dot.zshrc and dot.bashrc_additions)"

    # Check if dotfiles are properly linked
    if [ -L "$HOME/.zshrc" ] || [ -L "$HOME/.bashrc_additions" ]; then
        echo "✓ Dotfiles are properly linked"
    else
        echo "Note: Run dotfiles setup to link shell configuration files"
    fi
else
    echo "Dotfiles system not found, configuring shell files directly..."

    # Fallback to direct modification
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q "nodebrew" "$HOME/.bashrc"; then
            echo 'export PATH=$HOME/.nodebrew/current/bin:$PATH' >> "$HOME/.bashrc"
            echo "✓ Added nodebrew PATH to .bashrc"
            BASHRC_UPDATED=true
        else
            echo "✓ Nodebrew PATH already in .bashrc"
        fi
    fi

    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "nodebrew" "$HOME/.zshrc"; then
            echo 'export PATH=$HOME/.nodebrew/current/bin:$PATH' >> "$HOME/.zshrc"
            echo "✓ Added nodebrew PATH to .zshrc"
            ZSHRC_UPDATED=true
        else
            echo "✓ Nodebrew PATH already in .zshrc"
        fi
    fi
fi

echo ""
echo "Step 3: Installing Node.js stable version..."

# Check if stable version is already installed
if nodebrew ls | grep -q "stable"; then
    echo "✓ Node.js stable version already installed"
else
    echo "Installing Node.js stable version..."
    nodebrew install stable
    echo "✓ Node.js stable version installed"
fi

echo ""
echo "Step 4: Setting stable as current version..."

# Check if stable is already the current version
if nodebrew ls | grep "current:" | grep -q "stable"; then
    echo "✓ Node.js stable is already the current version"
else
    echo "Setting stable as current version..."
    nodebrew use stable
    echo "✓ Node.js stable set as current version"
fi

echo ""
echo "Step 5: Verifying installation..."

# Update PATH again to include nodebrew
export PATH=$HOME/.nodebrew/current/bin:$PATH

# Verify Node.js installation
if command -v node &> /dev/null; then
    echo "✓ Node.js installed successfully:"
    echo "  Node.js version: $(node --version)"

    if command -v npm &> /dev/null; then
        echo "  npm version: $(npm --version)"
    else
        echo "  npm: NOT FOUND"
    fi

    echo ""
    echo "Available Node.js versions:"
    nodebrew ls
else
    echo "✗ Node.js installation failed"
    echo "You may need to restart your terminal or run 'source ~/.bashrc'"
    exit 1
fi

echo ""
echo "Nodebrew and Node.js setup completed successfully!"
echo ""
echo "IMPORTANT:"
echo "- Nodebrew and Node.js stable are now installed"
echo "- You may need to restart your terminal for PATH changes to take effect"
if [ "$BASHRC_UPDATED" = true ] || [ "$ZSHRC_UPDATED" = true ]; then
    echo "- Or run one of the following to update your PATH:"
    if [ "$BASHRC_UPDATED" = true ]; then
        echo "  source ~/.bashrc"
    fi
    if [ "$ZSHRC_UPDATED" = true ]; then
        echo "  source ~/.zshrc"
    fi
fi
echo "- Use 'nodebrew install <version>' to install other Node.js versions"
echo "- Use 'nodebrew use <version>' to switch between versions"
echo "================================"
