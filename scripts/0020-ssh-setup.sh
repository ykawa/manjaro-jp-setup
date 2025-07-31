#!/bin/bash

# SSH Daemon Setup Script for Manjaro Linux
# This script enables and starts the SSH daemon for remote access

set -e

echo "================================"
echo "  SSH Daemon Setup Script"
echo "  For Manjaro Linux"
echo "================================"
echo ""

# Check if SSH daemon is already running
if systemctl is-active --quiet sshd; then
    echo "SSH daemon is already running:"
    echo "  Status: $(systemctl is-active sshd)"
    echo "  Enabled: $(systemctl is-enabled sshd)"
    SSH_PORT=$(sudo ss -tlnp | grep sshd | grep -o ':22 ' || echo ":22 ")
    echo "  SSH is available on port 22"
    echo "No changes needed."
    echo "================================"
    exit 0
fi

echo "Setting up SSH daemon..."
echo ""

# Install openssh if not already installed
if ! systemctl list-unit-files | grep -q "sshd.service"; then
    echo "Installing OpenSSH server..."
    sudo pacman -S --needed --noconfirm openssh
    echo "✓ OpenSSH server installed"
else
    echo "OpenSSH server is already installed"
fi

echo ""
echo "Enabling SSH daemon..."

# Enable SSH service to start on boot
sudo systemctl enable sshd
echo "✓ SSH daemon enabled for startup"

# Start SSH service
echo "Starting SSH daemon..."
sudo systemctl start sshd

echo ""
echo "Verifying SSH daemon status..."

# Check SSH status
if systemctl is-active --quiet sshd; then
    echo "✓ SSH daemon is running successfully"
    echo "  Status: $(systemctl is-active sshd)"
    echo "  Enabled: $(systemctl is-enabled sshd)"

    # Show SSH port information
    SSH_PORT=$(sudo ss -tlnp | grep sshd | grep -o ':22 ' || echo ":22 ")
    echo "  SSH is available on port 22"

    # Show network interfaces for connection info
    echo ""
    echo "Network interfaces for SSH connections:"
    ip -4 addr show | grep inet | grep -v 127.0.0.1 | awk '{print "  " $2}' || echo "  No network interfaces found"
else
    echo "✗ Failed to start SSH daemon"
    echo "Checking status..."
    systemctl status sshd --no-pager || true
    exit 1
fi

echo ""
echo "SSH daemon setup completed successfully!"
echo ""
echo "IMPORTANT:"
echo "- SSH daemon is now running and enabled"
echo "- Remote connections are available on port 22"
echo "- Make sure your firewall allows SSH connections if needed"
echo "- Use 'ssh username@ip-address' to connect remotely"
echo "================================"
