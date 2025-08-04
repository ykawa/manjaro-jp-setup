#!/bin/bash

# Zsh Installation and Setup Script for Manjaro Linux
# This script installs zsh and sets it as the default shell
# Requires yay to be installed first

set -e

echo "================================"
echo "  Zsh Installation Script"
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

# Check if zsh is already installed
if command -v zsh &> /dev/null; then
    echo "Zsh is already installed:"
    zsh --version

    # Check if zsh is already the default shell
    if [ "$SHELL" = "/usr/bin/zsh" ] || [ "$SHELL" = "/bin/zsh" ]; then
        echo "Zsh is already the default shell."
        echo "================================"
        exit 0
    fi
else
    echo "Installing zsh and useful packages..."
    yay -S --needed --noconfirm \
        zsh \
        zsh-completions \
        zsh-syntax-highlighting \
        zsh-autosuggestions \
        zsh-history-substring-search \
        zsh-theme-powerlevel10k

    echo ""
    echo "Verifying zsh installation..."
    if command -v zsh &> /dev/null; then
        echo "✓ Zsh installed successfully:"
        zsh --version
    else
        echo "✗ Zsh installation failed"
        exit 1
    fi
fi

echo ""
echo "Setting zsh as default shell for user: $CURRENT_USER"

# Get the full path to zsh
ZSH_PATH=$(which zsh)
echo "Zsh path: $ZSH_PATH"

# Check if zsh is in /etc/shells
if ! grep -q "$ZSH_PATH" /etc/shells; then
    echo "Adding zsh to /etc/shells..."
    echo "$ZSH_PATH" | sudo tee -a /etc/shells
fi

# Change default shell
echo "Changing default shell to zsh..."
sudo chsh -s "$ZSH_PATH" "$CURRENT_USER"

echo ""
echo "Setting up .zshrc via dotfiles management..."

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_SCRIPT="$SCRIPT_DIR/../0050-dotfiles-setup.sh"

# Check if dotfiles script exists
if [ ! -f "$DOTFILES_SCRIPT" ]; then
    echo "Warning: Dotfiles script not found at $DOTFILES_SCRIPT"
    echo "Creating basic .zshrc directly..."
    # Fallback to direct creation if dotfiles script doesn't exist
    if [ ! -f "$HOME/.zshrc" ] || ! grep -q "# Enhanced zsh configuration" "$HOME/.zshrc"; then
        if [ -f "$HOME/.zshrc" ] && [ ! -f "$HOME/.zshrc.backup" ]; then
            echo "Backing up existing .zshrc..."
            cp "$HOME/.zshrc" "$HOME/.zshrc.backup"
        fi

        echo "Creating basic .zshrc..."
        cat > "$HOME/.zshrc" << 'EOF'
# Basic zsh configuration
autoload -U colors && colors
PS1="%{$fg[green]%}[%n@%m %{$fg[blue]%}%~%{$fg[green]%}]%{$reset_color%}$ "
EOF
    fi
else
    echo "Running dotfiles setup for .zshrc..."
    "$DOTFILES_SCRIPT" setup

    # Verify that .zshrc symlink was created
    if [ -L "$HOME/.zshrc" ]; then
        echo "✓ .zshrc configured via dotfiles management"
    else
        echo "Warning: .zshrc symlink not created, check dotfiles setup"
    fi
fi

echo ""
echo "Zsh installation and setup completed successfully!"
echo ""
echo "IMPORTANT:"
echo "- Please restart your terminal or run 'exec zsh' to start using zsh"
echo "- Your default shell has been changed to: $ZSH_PATH"
echo "- An enhanced .zshrc configuration has been created with:"
echo "  * Powerlevel10k theme (run 'p10k configure' to customize)"
echo "  * Syntax highlighting"
echo "  * Auto-suggestions"
echo "  * History substring search"
echo "  * Enhanced completion"
echo "  * Useful aliases and key bindings"
echo "================================"
