#!/bin/bash

# Base Development Tools Installation Script for Manjaro Linux
# This script installs essential development tools and utilities
# Requires yay to be installed first

set -e

# Check if yay is available
if ! command -v yay &> /dev/null; then
    echo "Error: yay is not installed. Please run 0090-yay-install.sh first."
    exit 1
fi

echo "========================================"
echo "  Base Development Tools Installation"
echo "  For Manjaro Linux"
echo "========================================"
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

    echo "✓ Rust toolchain installed successfully!"
else
    echo "rustup already installed, checking components..."
    rustup default stable
    rustup component add clippy rls rust-analysis rust-src rustfmt rust-analyzer
    echo "✓ Rust components updated"
fi

echo ""
echo "========================================"
echo "  Base Development Tools Installation"
echo "  Completed Successfully"
echo "========================================"
echo ""
echo "Installed packages:"
echo "• Base development tools (base-devel, git, vim, make, cmake, gcc, g++)"
echo "• Programming languages (python, nodejs)"
echo "• Command-line utilities (curl, wget, jq, ripgrep, fd, bat, exa)"
echo "• Development tools (tmux, screen, tree, htop)"
echo "• Rust toolchain with components"
echo ""
echo "Next recommended steps:"
echo "• Run language-specific setup scripts (0110-*.sh)"
echo "• Configure your development environment"
echo "• Install additional tools as needed"
echo ""
