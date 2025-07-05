#!/bin/bash

# Base Development Tools Installation Script for Manjaro Linux
# This script installs essential development tools and utilities
# Requires yay to be installed first

set -e

# Check if yay is available
if ! command -v yay &> /dev/null; then
    echo "Error: yay is not installed. Please run 00990-yay-install.sh first."
    exit 1
fi

echo "========================================"
echo "  Base Development Tools Installation"
echo "  For Manjaro Linux"
echo "========================================"
echo ""

# Remove unwanted packages first
echo "Removing unwanted packages..."

# Remove packages one by one to ensure complete removal
packages_to_remove=("clipit" "pidgin" "pidgin-libnotify" "vivaldi" "vivaldi-bin" "vivaldi-stable" "nano" "nano-syntax-highlighting" "micro" "celluloid" "lollypop" "mpv")

for package in "${packages_to_remove[@]}"; do
    if pacman -Q "$package" >/dev/null 2>&1; then
        echo "Removing $package..."
        yay -R --noconfirm "$package" 2>/dev/null || echo "Failed to remove $package"
    else
        echo "$package not installed, skipping"
    fi
done

# Also remove vivaldi configuration and cache
echo "Removing Vivaldi configuration and cache..."
rm -rf "$HOME/.config/vivaldi" "$HOME/.cache/vivaldi" 2>/dev/null || true

# Remove lib32 packages
echo "Removing lib32 packages..."
yay -R --noconfirm $(pacman -Q | grep "^lib32-" | cut -d' ' -f1) 2>/dev/null || echo "No lib32 packages found"

echo ""
echo "Installing base development tools..."
yay -S --needed --noconfirm \
    base-devel \
    git \
    vim \
    make \
    cmake \
    gcc \
    g++ \
    python \
    python-pip \
    nodejs \
    npm \
    curl \
    wget \
    unzip \
    zip \
    tree \
    htop \
    neofetch

echo ""
echo "Installing additional development utilities..."
yay -S --needed --noconfirm \
    jq \
    ripgrep \
    fd \
    bat \
    exa \
    tldr \
    tmux \
    screen \
    nkf \
    peco \
    pv \
    xclip \
    grc \
    fwupd \
    cpio

# Install rustup and Rust toolchain
echo ""
echo "Installing rustup and Rust toolchain..."
if ! command -v rustup &> /dev/null; then
    echo "Installing rustup..."
    yay -S --needed --noconfirm rustup

    echo "Setting up Rust stable toolchain..."
    rustup default stable

    echo "Installing Rust components..."
    rustup component add clippy rls rust-analysis rust-src rustfmt rust-analyzer

    echo "Rust toolchain installed successfully!"
else
    echo "rustup already installed, checking components..."
    rustup default stable
    rustup component add clippy rls rust-analysis rust-src rustfmt rust-analyzer
fi

# Configure lib32 package prevention
echo ""
echo "Configuring pacman to ignore lib32 packages..."
if ! grep -q "IgnorePkg.*lib32-" /etc/pacman.conf; then
    sudo sed -i '/^#IgnorePkg/a IgnorePkg = lib32-*' /etc/pacman.conf
fi

echo ""
echo "Base development tools installation completed successfully!"
echo "========================================"
