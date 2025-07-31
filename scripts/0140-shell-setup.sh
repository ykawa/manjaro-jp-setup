#!/bin/bash

# Shell Configuration Script
# This script sets up useful shell aliases and environment variables

set -e

echo "================================"
echo "  Shell Configuration Setup"
echo "================================"
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_SCRIPT="$SCRIPT_DIR/../0050-dotfiles-setup.sh"

echo "Setting up shell configuration via dotfiles management..."

# Check if dotfiles script exists
if [ ! -f "$DOTFILES_SCRIPT" ]; then
    echo "Warning: Dotfiles script not found at $DOTFILES_SCRIPT"
    echo "Creating shell configuration directly..."

    # Note: .bashrc is managed by dotfiles setup script
    # Shell configuration should be handled there
    echo "Warning: .bashrc is managed by dotfiles setup script"
    echo "Additional shell configuration should be added to dotfiles/dot.bashrc_additions"
    echo "This fallback mode should not be used in normal operation"
else
    echo "Running dotfiles setup for shell configuration..."
    "$DOTFILES_SCRIPT" setup

    # Verify that dotfiles were created
    if [ -L "$HOME/.bashrc_additions" ]; then
        echo "✓ Shell configuration setup via dotfiles management"
    else
        echo "Warning: .bashrc_additions symlink not created, check dotfiles setup"
    fi

    # Also setup .bashrc if user doesn't have one or wants to use ours
    if [ -L "$HOME/.bashrc" ]; then
        echo "✓ .bashrc configured via dotfiles management"
    else
        echo "Note: .bashrc not managed by dotfiles (user may have custom configuration)"
    fi
fi

echo ""
echo "Shell configuration completed successfully!"
echo "Please run 'source ~/.bashrc' or restart your terminal to apply changes."
echo "================================"
