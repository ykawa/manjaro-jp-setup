#!/bin/bash

# Network Bridge Setup Script for Manjaro Linux
# This script creates a br0 bridge if a wired LAN interface is detected
# Uses NetworkManager for configuration
# Skips setup in virtual environments where bridge creation may not be supported

set -e

echo "================================"
echo "  Network Bridge Setup"
echo "  For Manjaro Linux"
echo "================================"
echo ""

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

# Check if we're in a virtual environment
if is_virtual_environment; then
    echo "🔍 Virtual environment detected: $(get_virtualization_type 2>/dev/null || echo "unknown")"
    echo ""
    echo "⚠️  Bridge networking setup is being skipped because:"
    echo "   • Virtual environments often don't support bridge creation"
    echo "   • Guest VMs typically use NAT or host-only networking"
    echo "   • Bridge interfaces may conflict with hypervisor networking"
    echo ""
    echo "If you specifically need bridge networking in this virtual environment,"
    echo "please configure it manually after ensuring your hypervisor supports it."
    echo ""
    echo "================================"
    echo "  Bridge Setup Skipped"
    echo "================================"
    exit 0
fi

echo "✓ Physical hardware detected - proceeding with bridge setup"
echo ""

# Check if NetworkManager is available
if ! command -v nmcli &> /dev/null; then
    echo "Error: NetworkManager (nmcli) is not installed."
    echo "Please install NetworkManager first: yay -S --needed --noconfirm networkmanager"
    exit 1
fi

# Function to get active wired ethernet interface
get_wired_interface() {
    # Get active ethernet interfaces (exclude virtual interfaces)
    local interfaces=$(nmcli -t -f DEVICE,TYPE,STATE device | grep -E ":ethernet:connected$" | cut -d: -f1)

    # Filter out virtual interfaces (docker, virbr, etc.)
    for interface in $interfaces; do
        if [[ ! "$interface" =~ ^(docker|virbr|br|veth|tap) ]]; then
            echo "$interface"
            return 0
        fi
    done

    return 1
}

# Function to check if bridge already exists
bridge_exists() {
    nmcli connection show | grep -q "^br0"
}

# Function to create bridge
create_bridge() {
    local ethernet_interface="$1"

    echo "Creating bridge br0 with interface $ethernet_interface..."

    # Check if bridge already exists
    if bridge_exists; then
        echo "Bridge br0 already exists. Checking configuration..."

        # Check if the ethernet interface is already part of the bridge
        if nmcli connection show | grep -q "br0-port"; then
            echo "Bridge br0 is already configured. Skipping creation."
            return 0
        else
            echo "Bridge br0 exists but not fully configured. Completing setup..."
        fi
    else
        # Create bridge connection
        echo "Creating bridge connection br0..."
        nmcli connection add type bridge con-name br0 ifname br0
    fi

    # Create bridge port connection
    echo "Adding $ethernet_interface to bridge br0..."
    nmcli connection add type ethernet con-name br0-port-1 ifname "$ethernet_interface" master br0

    # Configure DNS settings (AdGuard DNS)
    echo "Configuring DNS settings..."
    nmcli connection modify br0 ipv4.dns "94.140.14.14,94.140.15.15"
    nmcli connection modify br0 ipv4.ignore-auto-dns yes
    nmcli connection modify br0 ipv6.dns "2a10:50c0::ad1:ff,2a10:50c0::ad2:ff"
    nmcli connection modify br0 ipv6.ignore-auto-dns yes

    # Bring up the bridge
    echo "Activating bridge connections..."
    nmcli connection up br0
    nmcli connection up br0-port-1

    echo "Bridge br0 created and configured successfully!"
    echo "Interface: $ethernet_interface"
    echo "DNS: AdGuard DNS (IPv4: 94.140.14.14, 94.140.15.15)"
    echo "DNS: AdGuard DNS (IPv6: 2a10:50c0::ad1:ff, 2a10:50c0::ad2:ff)"
}

# Function to show bridge status
show_bridge_status() {
    echo ""
    echo "Bridge Status:"
    echo "================================"
    nmcli connection show | grep -E "(br0|TYPE)" || echo "No bridge connections found"
    echo ""
    echo "Network Interfaces:"
    echo "================================"
    nmcli device status | grep -E "(DEVICE|br0|ethernet)"
}

# Main logic
echo "Checking for wired ethernet interfaces..."

# Get the active wired ethernet interface
if ethernet_interface=$(get_wired_interface); then
    echo "Found active wired ethernet interface: $ethernet_interface"

    # Check if this interface is already part of a bridge
    if nmcli connection show | grep -q "$ethernet_interface.*br0"; then
        echo "Interface $ethernet_interface is already part of bridge br0"
    else
        # Create bridge if it doesn't exist or is not fully configured
        create_bridge "$ethernet_interface"
    fi

    # Show final status
    show_bridge_status

else
    echo "No active wired ethernet interface found."
    echo "Bridge creation skipped."
    echo ""
    echo "Available network interfaces:"
    nmcli device status
fi

echo ""
echo "Network bridge setup completed!"
echo "================================"
