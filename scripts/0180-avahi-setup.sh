#!/bin/bash

# Avahi Setup Script for Manjaro Linux
# This script installs and enables Avahi daemon for network service discovery

set -e

echo "================================"
echo "  Avahi Setup Script"
echo "  For Manjaro Linux"
echo "================================"
echo ""

# Get current user
CURRENT_USER=$(whoami)
echo "Current user: $CURRENT_USER"
echo ""

echo "Step 1: Checking Avahi installation status..."

# Check if Avahi is already installed
if pacman -Qi avahi &>/dev/null; then
    echo "✓ Avahi is already installed"
    AVAHI_INSTALLED=true
else
    echo "- Avahi is not installed"
    AVAHI_INSTALLED=false
fi

# Check if yay is available for potential AUR packages
if command -v yay &> /dev/null; then
    PACKAGE_MANAGER="yay"
    echo "✓ Using yay for package installation"
else
    PACKAGE_MANAGER="pacman"
    echo "✓ Using pacman for package installation"
fi

echo ""
echo "Step 2: Installing Avahi if needed..."

if [ "$AVAHI_INSTALLED" = false ]; then
    echo "Installing Avahi packages..."

    if [ "$PACKAGE_MANAGER" = "yay" ]; then
        yay -S --needed --noconfirm avahi nss-mdns
    else
        sudo pacman -S --needed --noconfirm avahi nss-mdns
    fi

    echo "✓ Avahi packages installed"
else
    echo "✓ Avahi packages already installed"

    # Ensure additional packages are installed
    if [ "$PACKAGE_MANAGER" = "yay" ]; then
        yay -S --needed --noconfirm nss-mdns
    else
        sudo pacman -S --needed --noconfirm nss-mdns
    fi
fi

echo ""
echo "Step 3: Checking Avahi daemon service status..."

# Check if avahi-daemon is enabled
if systemctl is-enabled avahi-daemon.service >/dev/null 2>&1; then
    echo "✓ avahi-daemon.service is enabled"
    AVAHI_ENABLED=true
else
    echo "- avahi-daemon.service is not enabled"
    AVAHI_ENABLED=false
fi

# Check if avahi-daemon is active
if systemctl is-active avahi-daemon.service >/dev/null 2>&1; then
    echo "✓ avahi-daemon.service is active"
    AVAHI_ACTIVE=true
else
    echo "- avahi-daemon.service is not active"
    AVAHI_ACTIVE=false
fi

echo ""
echo "Step 4: Enabling and starting Avahi daemon..."

# Enable avahi-daemon service if not already enabled
if [ "$AVAHI_ENABLED" = false ]; then
    echo "Enabling avahi-daemon.service..."
    sudo systemctl enable avahi-daemon.service
    echo "✓ avahi-daemon.service enabled"
else
    echo "✓ avahi-daemon.service already enabled"
fi

# Start avahi-daemon service if not already active
if [ "$AVAHI_ACTIVE" = false ]; then
    echo "Starting avahi-daemon.service..."
    sudo systemctl start avahi-daemon.service
    echo "✓ avahi-daemon.service started"
else
    echo "✓ avahi-daemon.service already active"
fi

echo ""
echo "Step 5: Configuring NSS for mDNS resolution..."

# Check if /etc/nsswitch.conf is configured for mDNS
NSS_CONFIG="/etc/nsswitch.conf"

# Backup NSS configuration if no backup exists yet
if [ ! -f "$NSS_CONFIG.backup" ]; then
    echo "Backing up $NSS_CONFIG..."
    sudo cp "$NSS_CONFIG" "$NSS_CONFIG.backup"
fi

# Check current hosts configuration
if grep -q "^hosts:" "$NSS_CONFIG"; then
    CURRENT_HOSTS=$(grep "^hosts:" "$NSS_CONFIG")
    echo "Current hosts configuration: $CURRENT_HOSTS"

    # Check if configuration needs updating
    if echo "$CURRENT_HOSTS" | grep -q "mymachines.*mdns4_minimal" && \
       echo "$CURRENT_HOSTS" | grep -q "\[NOTFOUND=return\]"; then
        echo "✓ NSS already properly configured for mDNS resolution"
    else
        echo "Updating NSS configuration for proper mDNS resolution..."

        # Extract existing configuration parts
        HOSTS_LINE=$(echo "$CURRENT_HOSTS" | sed 's/^hosts: *//')

        # Build new configuration with proper ordering
        NEW_CONFIG="hosts:"

        # 1. Add mymachines if not present, or move to front
        if echo "$HOSTS_LINE" | grep -q "mymachines"; then
            NEW_CONFIG="$NEW_CONFIG mymachines"
            # Remove mymachines from existing line for later processing
            HOSTS_LINE=$(echo "$HOSTS_LINE" | sed 's/mymachines[ ]*//')
        else
            NEW_CONFIG="$NEW_CONFIG mymachines"
        fi

        # 2. Add mdns4_minimal if not present, or ensure it's after mymachines
        if echo "$HOSTS_LINE" | grep -q "mdns4_minimal"; then
            NEW_CONFIG="$NEW_CONFIG mdns4_minimal"
            # Remove mdns4_minimal from existing line for later processing
            HOSTS_LINE=$(echo "$HOSTS_LINE" | sed 's/mdns4_minimal[ ]*//')
        else
            NEW_CONFIG="$NEW_CONFIG mdns4_minimal"
        fi

        # 3. Add [NOTFOUND=return] if it was present, or add it
        if echo "$HOSTS_LINE" | grep -q "\[NOTFOUND=return\]"; then
            NEW_CONFIG="$NEW_CONFIG [NOTFOUND=return]"
            # Remove [NOTFOUND=return] from existing line for later processing
            HOSTS_LINE=$(echo "$HOSTS_LINE" | sed 's/\[NOTFOUND=return\][ ]*//')
        else
            NEW_CONFIG="$NEW_CONFIG [NOTFOUND=return]"
        fi

        # 4. Add remaining services (files, dns, etc.)
        # Clean up any remaining services and add them
        REMAINING_SERVICES=$(echo "$HOSTS_LINE" | sed 's/^[ ]*//' | sed 's/[ ]*$//')
        if [ -n "$REMAINING_SERVICES" ]; then
            # Ensure files and dns are present if not already specified
            if ! echo "$REMAINING_SERVICES" | grep -q "files"; then
                REMAINING_SERVICES="files $REMAINING_SERVICES"
            fi
            if ! echo "$REMAINING_SERVICES" | grep -q "dns"; then
                REMAINING_SERVICES="$REMAINING_SERVICES dns"
            fi
            NEW_CONFIG="$NEW_CONFIG $REMAINING_SERVICES"
        else
            # Default services if none were present
            NEW_CONFIG="$NEW_CONFIG files dns"
        fi

        # Apply the new configuration
        sudo sed -i "s/^hosts:.*/$NEW_CONFIG/" "$NSS_CONFIG"
        echo "✓ Updated NSS configuration with proper mDNS ordering"
        echo "New configuration: $NEW_CONFIG"
    fi
else
    # Add hosts line if it doesn't exist
    echo "No hosts configuration found, creating with proper mDNS setup..."
    NEW_CONFIG="hosts: mymachines mdns4_minimal [NOTFOUND=return] files dns"
    echo "$NEW_CONFIG" | sudo tee -a "$NSS_CONFIG" > /dev/null
    echo "✓ Added hosts line with proper mDNS configuration"
    echo "New configuration: $NEW_CONFIG"
fi

echo ""
echo "Step 6: Verifying Avahi setup..."

# Wait a moment for services to stabilize
sleep 2

# Verify service status
echo "Final service status:"
if systemctl is-enabled avahi-daemon.service >/dev/null 2>&1 && \
   systemctl is-active avahi-daemon.service >/dev/null 2>&1; then
    echo "✓ avahi-daemon.service: enabled and active"
else
    echo "✗ avahi-daemon.service: configuration issue"
    exit 1
fi

# Check if Avahi is responding
if command -v avahi-browse &>/dev/null; then
    echo "✓ Avahi tools available"
    echo "- You can use 'avahi-browse -a' to discover services"
else
    echo "⚠ Avahi tools not available (install avahi-utils for additional tools)"
fi

echo ""
echo "Avahi setup completed successfully!"
echo ""
echo "SUMMARY:"
echo "✓ Avahi daemon installed and configured"
echo "✓ avahi-daemon.service enabled and active"
echo "✓ NSS configured for mDNS resolution"
echo "✓ Network service discovery is now available"
echo ""
echo "FUNCTIONALITY:"
echo "- Automatic discovery of network services (printers, file shares, etc.)"
echo "- .local domain resolution (e.g., hostname.local)"
echo "- Zero-configuration networking support"
echo "- Integration with applications that support Bonjour/Zeroconf"
echo ""
echo "USAGE EXAMPLES:"
echo "- Access other machines: ssh user@hostname.local"
echo "- Browse network services: avahi-browse -a (if avahi-utils installed)"
echo "- Your machine is now discoverable as: $(hostname).local"
echo ""
echo "IMPORTANT:"
echo "- Avahi enables .local domain resolution automatically"
echo "- Network services will be discoverable by other Avahi-enabled devices"
echo "- This improves network connectivity in mixed environments"
echo "================================"
