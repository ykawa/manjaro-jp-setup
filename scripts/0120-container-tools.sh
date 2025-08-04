#!/bin/bash

# Container Tools Installation Script for Manjaro Linux
# This script installs Docker and related container tools

set -e

# Check if yay is available
if ! command -v yay &> /dev/null; then
    echo "Error: yay is not installed. Please run 00990-yay-install.sh first."
    exit 1
fi

echo "=================================="
echo "  Container Tools Installation"
echo "  For Manjaro Linux"
echo "=================================="
echo ""

echo "Installing Docker and container tools..."
yay -S --needed --noconfirm \
    docker \
    docker-compose \
    docker-buildx

# Configure Docker for user access
echo ""
echo "Configuring Docker for user access..."
sudo usermod -aG docker $USER
sudo systemctl enable docker
sudo systemctl start docker

echo ""
echo "Container tools installation completed successfully!"
echo "Docker access requires re-login to take effect."
echo "=================================="
