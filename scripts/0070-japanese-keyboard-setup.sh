#!/bin/bash

# Japanese 106-key Keyboard Setup Script for Manjaro Linux
# This script configures Japanese 106-key keyboard layout for both virtual console and X11

set -e

echo "================================"
echo "  Japanese 106-key Keyboard Setup"
echo "  For Manjaro Linux"
echo "================================"
echo ""

# Get current user
CURRENT_USER=$(whoami)
echo "Current user: $CURRENT_USER"
echo ""

echo "Step 1: Configuring virtual console (vconsole) for Japanese keyboard..."

# Configure vconsole for Japanese keyboard
VCONSOLE_FILE="/etc/vconsole.conf"

# Backup existing vconsole.conf if it exists and no backup exists yet
if [ -f "$VCONSOLE_FILE" ] && [ ! -f "$VCONSOLE_FILE.backup" ]; then
    echo "Backing up existing $VCONSOLE_FILE..."
    sudo cp "$VCONSOLE_FILE" "$VCONSOLE_FILE.backup"
fi

# Check and update vconsole.conf with Japanese keyboard layout
echo "Configuring Japanese keyboard layout in $VCONSOLE_FILE..."

# Check if configuration already matches what we want
if [ -f "$VCONSOLE_FILE" ] && \
   grep -q "^KEYMAP=jp106" "$VCONSOLE_FILE" && \
   grep -q "^FONT=lat9w-16" "$VCONSOLE_FILE"; then
    echo "✓ Virtual console already configured for Japanese 106-key keyboard"
else
    # Create or update the configuration
    sudo tee "$VCONSOLE_FILE" > /dev/null << 'EOF'
# Virtual console configuration
KEYMAP=jp106
FONT=lat9w-16
EOF
    echo "✓ Virtual console configured for Japanese 106-key keyboard"
fi

echo ""
echo "Step 2: Loading Japanese keyboard layout for current session..."

# Load the Japanese keymap for the current session
if command -v loadkeys &> /dev/null; then
    sudo loadkeys jp106
    echo "✓ Japanese keyboard layout loaded for current session"
else
    echo "⚠ loadkeys command not found, layout will be applied on next boot"
fi

echo ""
echo "Step 3: Configuring X11 for Japanese keyboard..."

# Create X11 keyboard configuration
X11_KEYBOARD_CONF="/etc/X11/xorg.conf.d/00-keyboard.conf"

echo "Creating X11 keyboard configuration: $X11_KEYBOARD_CONF"
sudo mkdir -p /etc/X11/xorg.conf.d/

sudo tee "$X11_KEYBOARD_CONF" > /dev/null << 'EOF'
# X11 Keyboard Configuration
# Japanese 106-key keyboard layout

Section "InputClass"
    Identifier "system-keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout" "jp"
    Option "XkbModel" "jp106"
    Option "XkbVariant" ""
    Option "XkbOptions" "ctrl:nocaps"
EndSection
EOF

echo "✓ X11 keyboard configuration created"

echo ""
echo "Step 4: Configuring locale for Japanese support..."

# Check if Japanese locale is available
if locale -a | grep -q "ja_JP.UTF-8"; then
    echo "✓ Japanese locale (ja_JP.UTF-8) is available"
else
    echo "Installing Japanese locale support..."
    # Uncomment ja_JP.UTF-8 in locale.gen if not already done
    if ! grep -q "^ja_JP.UTF-8" /etc/locale.gen; then
        sudo sed -i 's/^#ja_JP.UTF-8/ja_JP.UTF-8/' /etc/locale.gen
        sudo locale-gen
        echo "✓ Japanese locale generated"
    fi
fi

echo ""
echo "Step 5: Applying current session settings..."


# Apply keyboard layout for current X11 session if available
if [ -n "$DISPLAY" ] && command -v setxkbmap &> /dev/null; then
    echo "Applying Japanese keyboard layout for current X11 session..."
    setxkbmap -layout jp -model jp106
    echo "✓ Japanese keyboard layout applied to current session"
else
    echo "⚠ Not in X11 session or setxkbmap not available"
    echo "  Layout will be applied when X11 starts"
fi

echo ""
echo "Japanese 106-key keyboard setup completed successfully!"
echo ""
echo "SUMMARY:"
echo "✓ Virtual console configured for Japanese 106-key keyboard"
echo "✓ X11 configured for Japanese keyboard layout"
echo "✓ Japanese locale support configured"
echo ""
echo "IMPORTANT:"
echo "- Changes are applied to current session where possible"
echo "- Full effect will be visible after reboot or re-login"
echo "- For Japanese input, run the fcitx5 setup script (scripts/0190-fcitx5-setup.sh)"
echo ""
echo "NEXT STEPS:"
echo "1. Run the fcitx5 setup script to configure Japanese input"
echo "2. Reboot or log out and log back in for full effect"
echo "================================"
