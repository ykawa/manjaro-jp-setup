#!/bin/bash

# Claude Code Setup Script for Manjaro Linux
# This script installs Claude Code CLI tool

set -e

echo "================================"
echo "  Claude Code Setup Script"
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

# Check if Claude Code is already installed
if command -v claude &> /dev/null; then
    echo "Claude Code is already installed:"
    claude --version
    echo "No changes needed."
    echo "================================"
    exit 0
fi

echo "Installing Claude Code..."
echo ""

# Check if npm is available
if ! command -v npm &> /dev/null; then
    echo "ERROR: npm is not found."
    echo "Please install Node.js and npm first by running:"
    echo "  ./0003-nodebrew-setup.sh"
    exit 1
fi

echo "Using npm to install Claude Code CLI..."
echo "npm version: $(npm --version)"
echo ""

# Install Claude Code using npm
echo "Installing @anthropic-ai/claude-cli globally..."
npm install -g @anthropic-ai/claude-cli

echo ""
echo "Verifying Claude Code installation..."

# Update PATH to include npm global packages
export PATH=$HOME/.nodebrew/current/bin:$PATH

# Verify installation
if command -v claude &> /dev/null; then
    echo "✓ Claude Code installed successfully:"
    claude --version

    echo ""
    echo "Claude Code installation location:"
    which claude
else
    echo "✗ Claude Code installation failed"
    echo ""
    echo "Troubleshooting:"
    echo "1. Try restarting your terminal"
    echo "2. Run 'source ~/.bashrc' or 'source ~/.zshrc'"
    echo "3. Check if npm global packages are in your PATH"
    echo "4. You can also try: npm list -g @anthropic-ai/claude-cli"
    exit 1
fi

echo ""
echo "Claude Code setup completed successfully!"
echo ""
echo "IMPORTANT:"
echo "- Claude Code CLI is now installed and ready to use"
echo "- You may need to restart your terminal for PATH changes to take effect"
echo "- Run 'claude --help' to see available commands"
echo "- You may need to configure Claude Code with your API credentials"
echo "================================"
