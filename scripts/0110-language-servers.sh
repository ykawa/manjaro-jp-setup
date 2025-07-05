#!/bin/bash

# Language Servers Installation Script for Manjaro Linux
# This script installs various language servers for development

set -e

# Check if yay is available
if ! command -v yay &> /dev/null; then
    echo "Error: yay is not installed. Please run 00990-yay-install.sh first."
    exit 1
fi

echo "====================================="
echo "  Language Servers Installation"
echo "  For Manjaro Linux"
echo "====================================="
echo ""

# Install Language Servers via npm
echo ""
echo "Installing Language Servers via npm..."
sudo npm install -g \
    bash-language-server \
    typescript-language-server \
    vscode-langservers-extracted \
    yaml-language-server \
    dockerfile-language-server-nodejs \
    @ansible/ansible-language-server \
    pyright \
    vim-language-server \
    lua-language-server

echo ""
echo "Language servers installation completed successfully!"
echo "====================================="
