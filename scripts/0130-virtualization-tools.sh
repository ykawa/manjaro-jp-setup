#!/bin/bash

# Virtualization Tools Installation Script for Manjaro Linux
# This script installs QEMU, libvirt, and related virtualization tools
# Skips installation in virtual environments where nested virtualization may not be needed

set -e

# Load virtual environment detection library
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
if [ -f "$SCRIPT_DIR/../lib/virt-detect.sh" ]; then
    source "$SCRIPT_DIR/../lib/virt-detect.sh"
else
    echo "Warning: Virtual environment detection library not found"
    # Fallback simple detection
    is_virtual_environment() {
        if command -v systemd-detect-virt > /dev/null 2>&1; then
            [ "$(systemd-detect-virt)" != "none" ]
        else
            return 1
        fi
    }
fi

echo "======================================="
echo "  Virtualization Tools Installation"
echo "  For Manjaro Linux"
echo "======================================="
echo ""

# Check if we're in a virtual environment
if is_virtual_environment; then
    echo "🔍 Virtual environment detected: $(get_virtualization_type 2>/dev/null || echo "unknown")"
    echo ""
    echo "⚠️  Virtualization tools installation is being skipped because:"
    echo "   • Installing hypervisors inside virtual machines is usually unnecessary"
    echo "   • Nested virtualization may not be enabled or supported"
    echo "   • It can cause performance issues and conflicts"
    echo "   • Most use cases don't require VM-in-VM setups"
    echo ""
    echo "If you specifically need nested virtualization:"
    echo "   1. Enable nested virtualization in your host hypervisor"
    echo "   2. Manually install: yay -S qemu-full libvirt virt-manager"
    echo "   3. Configure libvirt and KVM modules appropriately"
    echo ""
    echo "======================================="
    echo "  Virtualization Tools Skipped"
    echo "======================================="
    exit 0
fi

echo "✓ Physical hardware detected - proceeding with virtualization tools installation"
echo ""

# Check if yay is available
if ! command -v yay &> /dev/null; then
    echo "Error: yay is not installed. Please run 0090-yay-install.sh first."
    exit 1
fi

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
