#!/bin/bash

# Virtualization Tools Installation Script for Manjaro Linux
# This script installs QEMU, libvirt, and related virtualization tools

set -e

# Check if yay is available
if ! command -v yay &> /dev/null; then
    echo "Error: yay is not installed. Please run 00990-yay-install.sh first."
    exit 1
fi

echo "======================================="
echo "  Virtualization Tools Installation"
echo "  For Manjaro Linux"
echo "======================================="
echo ""

echo "Installing virtualization tools..."
yay -S --needed --noconfirm \
    qemu-full \
    libvirt \
    virt-manager \
    virt-viewer \
    spice-vdagent \
    spice-gtk \
    spice-protocol \
    bridge-utils \
    dnsmasq \
    iptables-nft \
    dmidecode \
    edk2-ovmf

echo ""
echo "Installing 3D acceleration support..."
yay -S --needed --noconfirm \
    mesa \
    mesa-utils \
    vulkan-mesa-layers \
    vulkan-tools \
    qemu-hw-display-virtio-gpu \
    qemu-hw-display-virtio-gpu-gl \
    qemu-hw-display-virtio-vga \
    qemu-hw-display-virtio-vga-gl

# Configure libvirt for user access
echo ""
echo "Configuring libvirt for user access..."
sudo usermod -aG libvirt $USER
sudo systemctl enable libvirtd
sudo systemctl start libvirtd

# Configure default libvirt network
echo ""
echo "Configuring default libvirt network..."
sudo virsh net-autostart default 2>/dev/null || true
sudo virsh net-start default 2>/dev/null || true

echo ""
echo "Virtualization tools installation completed successfully!"
echo "Libvirt access requires re-login to take effect."
echo "Use 'virt-manager' to manage virtual machines."
echo "======================================="
