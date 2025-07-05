#!/bin/bash

# Mouse and Touchpad Configuration Script
# This script configures mouse and touchpad settings with high speed
# Mouse: normal scroll direction (natural for mouse)
# Touchpad: reverse scroll direction (natural for touchpad)

set -e

echo "========================================="
echo "  Mouse and Touchpad Configuration"
echo "  High Speed + Custom Scroll Settings"
echo "========================================="
echo ""

# Check if we're in a graphical session
if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
    echo "No graphical session detected. Settings will be applied when GUI is available."
    echo "Configuration files will be created for automatic loading."
fi

echo "Current desktop environment: ${XDG_CURRENT_DESKTOP:-Not set}"
echo "Current session type: ${XDG_SESSION_TYPE:-Not set}"
echo ""

# Function to detect and configure input devices using xinput
configure_xinput() {
    echo "Configuring input devices using xinput..."

    if ! command -v xinput &> /dev/null; then
        echo "xinput not found, skipping xinput configuration"
        return 1
    fi

    # List all input devices
    echo "Available input devices:"
    xinput list --short
    echo ""

    # Configure mouse devices
    echo "Configuring mouse devices..."
    mouse_devices=$(xinput list --short | grep -i mouse | grep -v touchpad | cut -d'=' -f2 | cut -d'[' -f1)

    for device_id in $mouse_devices; do
        if [ -n "$device_id" ]; then
            device_name=$(xinput list --name-only $device_id 2>/dev/null || echo "Unknown")
            echo "Configuring mouse device: $device_name (ID: $device_id)"

            # Set high acceleration and speed for mouse
            xinput set-prop $device_id "libinput Accel Speed" 0.8 2>/dev/null || echo "  Could not set acceleration"
            xinput set-prop $device_id "libinput Accel Profile Enabled" 0, 1 2>/dev/null || echo "  Could not set accel profile"

            # Mouse: normal scroll direction (no natural scrolling)
            xinput set-prop $device_id "libinput Natural Scrolling Enabled" 0 2>/dev/null || echo "  Could not set scroll direction"

            echo "  ✓ Mouse configured: high speed, normal scroll"
        fi
    done

    # Configure touchpad devices
    echo ""
    echo "Configuring touchpad devices..."
    touchpad_devices=$(xinput list --short | grep -i touchpad | cut -d'=' -f2 | cut -d'[' -f1)

    for device_id in $touchpad_devices; do
        if [ -n "$device_id" ]; then
            device_name=$(xinput list --name-only $device_id 2>/dev/null || echo "Unknown")
            echo "Configuring touchpad device: $device_name (ID: $device_id)"

            # Set high acceleration and speed for touchpad
            xinput set-prop $device_id "libinput Accel Speed" 0.7 2>/dev/null || echo "  Could not set acceleration"
            xinput set-prop $device_id "libinput Accel Profile Enabled" 0, 1 2>/dev/null || echo "  Could not set accel profile"

            # Touchpad: reverse scroll direction (natural scrolling)
            xinput set-prop $device_id "libinput Natural Scrolling Enabled" 1 2>/dev/null || echo "  Could not set scroll direction"

            # Enable tapping
            xinput set-prop $device_id "libinput Tapping Enabled" 1 2>/dev/null || echo "  Could not enable tapping"

            # Enable two-finger scrolling
            xinput set-prop $device_id "libinput Scroll Method Enabled" 0, 0, 1 2>/dev/null || echo "  Could not set scroll method"

            echo "  ✓ Touchpad configured: high speed, reverse scroll, tapping enabled"
        fi
    done
}

# Function to create X11 configuration files
create_x11_config() {
    echo "Creating X11 configuration files..."

    # Create X11 config directory if it doesn't exist
    sudo mkdir -p /etc/X11/xorg.conf.d/

    # Create mouse configuration
    sudo tee /etc/X11/xorg.conf.d/50-mouse.conf > /dev/null << 'EOF'
# Mouse configuration - High speed, normal scroll
Section "InputClass"
    Identifier "Mouse Configuration"
    MatchIsPointer "yes"
    MatchDevicePath "/dev/input/event*"
    Driver "libinput"
    Option "AccelSpeed" "0.8"
    Option "AccelProfile" "adaptive"
    Option "NaturalScrolling" "false"
    Option "ScrollMethod" "button"
EndSection
EOF

    # Create touchpad configuration
    sudo tee /etc/X11/xorg.conf.d/51-touchpad.conf > /dev/null << 'EOF'
# Touchpad configuration - High speed, reverse scroll
Section "InputClass"
    Identifier "Touchpad Configuration"
    MatchIsTouchpad "yes"
    MatchDevicePath "/dev/input/event*"
    Driver "libinput"
    Option "AccelSpeed" "0.7"
    Option "AccelProfile" "adaptive"
    Option "NaturalScrolling" "true"
    Option "Tapping" "true"
    Option "TappingDrag" "true"
    Option "TappingDragLock" "false"
    Option "ScrollMethod" "twofinger"
    Option "HorizontalScrolling" "true"
    Option "DisableWhileTyping" "true"
EndSection
EOF

    echo "✓ X11 configuration files created:"
    echo "  - /etc/X11/xorg.conf.d/50-mouse.conf"
    echo "  - /etc/X11/xorg.conf.d/51-touchpad.conf"
}

# Function to configure GNOME settings
configure_gnome() {
    if command -v gsettings &> /dev/null && (pgrep -x "gnome-shell" > /dev/null || [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]); then
        echo "Configuring GNOME mouse and touchpad settings..."

        # Mouse settings
        gsettings set org.gnome.desktop.peripherals.mouse speed 0.8
        gsettings set org.gnome.desktop.peripherals.mouse natural-scroll false
        gsettings set org.gnome.desktop.peripherals.mouse accel-profile 'adaptive'

        # Touchpad settings
        gsettings set org.gnome.desktop.peripherals.touchpad speed 0.7
        gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true
        gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
        gsettings set org.gnome.desktop.peripherals.touchpad two-finger-scrolling-enabled true
        gsettings set org.gnome.desktop.peripherals.touchpad disable-while-typing true

        echo "✓ GNOME settings configured"
    else
        echo "GNOME not detected, skipping GNOME configuration"
    fi
}

# Function to configure Cinnamon settings
configure_cinnamon() {
    if command -v gsettings &> /dev/null && (pgrep -x "cinnamon" > /dev/null || [ "$XDG_CURRENT_DESKTOP" = "X-Cinnamon" ]); then
        echo "Configuring Cinnamon mouse and touchpad settings..."

        # Mouse settings
        gsettings set org.cinnamon.desktop.peripherals.mouse speed 0.8
        gsettings set org.cinnamon.desktop.peripherals.mouse natural-scroll false

        # Touchpad settings
        gsettings set org.cinnamon.desktop.peripherals.touchpad speed 0.7
        gsettings set org.cinnamon.desktop.peripherals.touchpad natural-scroll true
        gsettings set org.cinnamon.desktop.peripherals.touchpad tap-to-click true
        gsettings set org.cinnamon.desktop.peripherals.touchpad two-finger-scrolling-enabled true
        gsettings set org.cinnamon.desktop.peripherals.touchpad disable-while-typing true

        echo "✓ Cinnamon settings configured"
    else
        echo "Cinnamon not detected, skipping Cinnamon configuration"
    fi
}

# Function to create startup script for automatic configuration
create_startup_script() {
    echo "Creating startup script for automatic configuration..."

    # Create autostart directory
    mkdir -p "$HOME/.config/autostart"

    # Create startup script
    cat > "$HOME/.local/bin/configure-input-devices.sh" << 'EOF'
#!/bin/bash
# Auto-configure mouse and touchpad on startup

sleep 2  # Wait for devices to be ready

# Configure using xinput if available
if command -v xinput &> /dev/null; then
    # Mouse devices - high speed, normal scroll
    xinput list --short | grep -i mouse | grep -v touchpad | while read line; do
        device_id=$(echo "$line" | cut -d'=' -f2 | cut -d'[' -f1)
        if [ -n "$device_id" ]; then
            xinput set-prop $device_id "libinput Accel Speed" 0.8 2>/dev/null
            xinput set-prop $device_id "libinput Natural Scrolling Enabled" 0 2>/dev/null
        fi
    done

    # Touchpad devices - high speed, reverse scroll
    xinput list --short | grep -i touchpad | while read line; do
        device_id=$(echo "$line" | cut -d'=' -f2 | cut -d'[' -f1)
        if [ -n "$device_id" ]; then
            xinput set-prop $device_id "libinput Accel Speed" 0.7 2>/dev/null
            xinput set-prop $device_id "libinput Natural Scrolling Enabled" 1 2>/dev/null
            xinput set-prop $device_id "libinput Tapping Enabled" 1 2>/dev/null
        fi
    done
fi
EOF

    chmod +x "$HOME/.local/bin/configure-input-devices.sh"

    # Create autostart entry
    cat > "$HOME/.config/autostart/configure-input-devices.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Configure Input Devices
Comment=Auto-configure mouse and touchpad settings
Exec=$HOME/.local/bin/configure-input-devices.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF

    echo "✓ Startup script created: $HOME/.local/bin/configure-input-devices.sh"
    echo "✓ Autostart entry created: $HOME/.config/autostart/configure-input-devices.desktop"
}

# Main configuration process
echo "Starting mouse and touchpad configuration..."
echo ""

# Create necessary directories
mkdir -p "$HOME/.local/bin"

# Apply configurations
create_x11_config
echo ""

if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
    configure_xinput
    echo ""
    configure_gnome
    echo ""
    configure_cinnamon
    echo ""
fi

create_startup_script

echo ""
echo "========================================="
echo "  Mouse and Touchpad Configuration"
echo "  Completed Successfully"
echo "========================================="
echo ""
echo "Configuration applied:"
echo "• Mouse: High speed (0.8), normal scroll direction"
echo "• Touchpad: High speed (0.7), reverse scroll direction"
echo "• Touchpad: Tap-to-click enabled"
echo "• Touchpad: Two-finger scrolling enabled"
echo ""
echo "Settings will be:"
echo "• Applied immediately (if in graphical session)"
echo "• Persistent through X11 configuration files"
echo "• Auto-applied on startup via autostart script"
echo ""
echo "Note: You may need to log out and log back in for"
echo "      all settings to take full effect."
echo ""
