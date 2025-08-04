#!/bin/bash

# Caps Lock to Ctrl Setup Script for Manjaro Linux
# This script configures Caps Lock to function as Ctrl for both virtual console and X11

set -e

echo "================================"
echo "  Caps Lock to Ctrl Setup"
echo "  For Manjaro Linux"
echo "================================"
echo ""

# Get current user
CURRENT_USER=$(whoami)
echo "Current user: $CURRENT_USER"
echo ""

echo "Step 1: Setting up virtual console (vconsole) key mapping..."

# Create vconsole configuration for virtual console
VCONSOLE_FILE="/etc/vconsole.conf"

# Backup existing vconsole.conf if it exists and no backup exists yet
if [ -f "$VCONSOLE_FILE" ] && [ ! -f "$VCONSOLE_FILE.backup" ]; then
    echo "Backing up existing $VCONSOLE_FILE..."
    sudo cp "$VCONSOLE_FILE" "$VCONSOLE_FILE.backup"
fi

# Check if KEYMAP is already set
if [ -f "$VCONSOLE_FILE" ] && grep -q "^KEYMAP=" "$VCONSOLE_FILE"; then
    echo "KEYMAP already configured in $VCONSOLE_FILE"
    echo "Current configuration:"
    grep "^KEYMAP=" "$VCONSOLE_FILE"
else
    echo "Setting KEYMAP in $VCONSOLE_FILE..."
    echo "KEYMAP=us" | sudo tee -a "$VCONSOLE_FILE" > /dev/null
    echo "✓ Added KEYMAP=us to $VCONSOLE_FILE"
fi

echo ""
echo "Step 2: Creating custom keymap for Caps Lock -> Ctrl..."

# Create custom keymap directory if it doesn't exist
KEYMAP_DIR="/usr/local/share/kbd/keymaps"
sudo mkdir -p "$KEYMAP_DIR"

# Create custom keymap files
CUSTOM_KEYMAP="$KEYMAP_DIR/caps-to-ctrl.map"
JP106_KEYMAP="$KEYMAP_DIR/jp106.map"

echo "Creating custom keymap: $CUSTOM_KEYMAP"
sudo tee "$CUSTOM_KEYMAP" > /dev/null << 'EOF'
# Custom keymap: Caps Lock -> Ctrl
# This remaps Caps Lock (keycode 58) to Left Ctrl

# Include the default US keymap
include "us"

# Remap Caps Lock to Left Ctrl
keycode 58 = Control
EOF

echo "✓ Custom keymap created"

echo ""
echo "Step 2.1: Creating Japanese 106-key keymap with Caps Lock -> Ctrl..."

# Create Japanese keymap with Caps Lock -> Ctrl modification
echo "Creating Japanese keymap with Caps Lock modification: $JP106_KEYMAP"
if [ -f "/usr/share/kbd/keymaps/i386/qwerty/jp106.map.gz" ]; then
    zcat /usr/share/kbd/keymaps/i386/qwerty/jp106.map.gz \
    | sed -E -e 's/keycode  58 =.*$/keycode  58 = Control/' \
    | sudo tee "$JP106_KEYMAP" > /dev/null
    echo "✓ Japanese keymap with Caps Lock -> Ctrl created"
else
    echo "⚠ jp106.map.gz not found, using standard US keymap"
fi

echo ""
echo "Step 2.2: Updating vconsole.conf to use Japanese keymap..."

# Update vconsole.conf to use the Japanese keymap with Caps Lock -> Ctrl
if [ -f "$JP106_KEYMAP" ]; then
    echo "Updating $VCONSOLE_FILE to use Japanese keymap..."
    sudo sed -i.bak -E -e "s|^KEYMAP=.*$|KEYMAP=$JP106_KEYMAP|" "$VCONSOLE_FILE"
    echo "✓ Updated vconsole.conf to use Japanese keymap"
else
    echo "⚠ Japanese keymap not available, keeping current configuration"
fi

echo ""
echo "Step 3: Loading keymap for current session..."

# Load the keymap for the current session
if command -v loadkeys &> /dev/null; then
    # Try to load Japanese keymap first, fall back to US keymap
    if [ -f "$JP106_KEYMAP" ]; then
        sudo loadkeys "$JP106_KEYMAP"
        echo "✓ Japanese keymap loaded for current session"
    else
        sudo loadkeys "$CUSTOM_KEYMAP"
        echo "✓ US keymap loaded for current session"
    fi
else
    echo "⚠ loadkeys command not found, keymap will be applied on next boot"
fi

echo ""
echo "Step 4: Setting up X11 key mapping..."

# Check if dotfiles management is available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_SCRIPT="$SCRIPT_DIR/../0050-dotfiles-setup.sh"

if [ -f "$DOTFILES_SCRIPT" ] && [ -f "$SCRIPT_DIR/../dotfiles/dot.Xmodmap" ]; then
    echo "Setting up X11 keymap via dotfiles management..."
    "$DOTFILES_SCRIPT" setup

    if [ -L "$HOME/.Xmodmap" ]; then
        echo "✓ X11 keymap configured via dotfiles management"
    else
        echo "Warning: .Xmodmap symlink not created, check dotfiles setup"
    fi
else
    echo "Dotfiles system not found, creating .Xmodmap directly..."

    # Fallback to direct creation
    XMODMAP_FILE="$HOME/.Xmodmap"
    echo "Creating X11 keymap configuration: $XMODMAP_FILE"
    cat > "$XMODMAP_FILE" << 'EOF'
! Xmodmap configuration
! Remap Caps Lock to Ctrl

! Clear caps lock
clear Lock

! Set caps lock to control
keycode 66 = Control_L

! Add to control modifier
add Control = Control_L
EOF
    echo "✓ X11 keymap configuration created"
fi

echo ""
echo "Step 4.1: Configuring system keyboard settings..."

# Configure /etc/default/keyboard for X11 keyboard options
KEYBOARD_FILE="/etc/default/keyboard"

# Create /etc/default/keyboard if it doesn't exist
if [ ! -f "$KEYBOARD_FILE" ]; then
    echo "Creating $KEYBOARD_FILE..."
    sudo tee "$KEYBOARD_FILE" > /dev/null << 'EOF'
# KEYBOARD CONFIGURATION FILE

# Consult the keyboard(5) manual page.

XKBMODEL="pc105"
XKBLAYOUT="jp"
XKBVARIANT=""
XKBOPTIONS="ctrl:nocaps"

BACKSPACE="guess"
EOF
    echo "✓ Created $KEYBOARD_FILE with Japanese keyboard and Caps Lock -> Ctrl"
else
    echo "Updating $KEYBOARD_FILE..."
    # Backup existing keyboard file if no backup exists
    if [ ! -f "$KEYBOARD_FILE.backup" ]; then
        sudo cp "$KEYBOARD_FILE" "$KEYBOARD_FILE.backup"
    fi

    # Check if XKBOPTIONS already contains ctrl:nocaps
    if grep -q "^XKBOPTIONS=.*ctrl:nocaps" "$KEYBOARD_FILE"; then
        echo "✓ XKBOPTIONS already contains ctrl:nocaps"
    elif grep -q "^XKBOPTIONS=" "$KEYBOARD_FILE"; then
        # Update existing XKBOPTIONS
        current_options=$(grep "^XKBOPTIONS=" "$KEYBOARD_FILE" | sed 's/^XKBOPTIONS="\(.*\)"$/\1/')
        if [ -z "$current_options" ]; then
            new_options="ctrl:nocaps"
        else
            new_options="$current_options,ctrl:nocaps"
        fi
        sudo sed -i "s/^XKBOPTIONS=.*/XKBOPTIONS=\"$new_options\"/" "$KEYBOARD_FILE"
        echo "✓ Updated XKBOPTIONS to include ctrl:nocaps"
    else
        # Add new XKBOPTIONS line
        echo 'XKBOPTIONS="ctrl:nocaps"' | sudo tee -a "$KEYBOARD_FILE" > /dev/null
        echo "✓ Added XKBOPTIONS to $KEYBOARD_FILE"
    fi
fi

echo ""
echo "Step 5: Setting up automatic X11 keymap loading..."

# Check if dotfiles system has X11 configuration files
if [ -f "$DOTFILES_SCRIPT" ] && [ -f "$SCRIPT_DIR/../dotfiles/dot.xinitrc" ] && [ -f "$SCRIPT_DIR/../dotfiles/dot.xprofile" ]; then
    echo "Setting up X11 startup files via dotfiles management..."
    "$DOTFILES_SCRIPT" setup

    # Check if files are properly linked
    if [ -L "$HOME/.xinitrc" ] && [ -L "$HOME/.xprofile" ]; then
        echo "✓ X11 startup files configured via dotfiles management"
    else
        echo "Note: X11 startup files may need manual dotfiles setup"
    fi

    # Check shell configuration (should already be configured in dotfiles)
    if [ -L "$HOME/.zshrc" ] && grep -q "xmodmap.*Xmodmap" "$HOME/.zshrc" 2>/dev/null; then
        echo "✓ Shell configuration already includes X11 keymap loading"
    else
        echo "Note: Shell configuration for X11 keymap loading may need verification"
    fi
else
    echo "Dotfiles system not found, configuring X11 files directly..."

    # Fallback to direct creation
    XINITRC_FILE="$HOME/.xinitrc"
    if ! grep -q "xmodmap.*Xmodmap" "$XINITRC_FILE" 2>/dev/null; then
        echo "Adding to $XINITRC_FILE..."
        {
            echo ""
            echo "# Load custom key mappings"
            echo "[ -f ~/.Xmodmap ] && xmodmap ~/.Xmodmap"
        } >> "$XINITRC_FILE"
        echo "✓ Added to .xinitrc"
    else
        echo "✓ .xinitrc already configured"
    fi

    XPROFILE_FILE="$HOME/.xprofile"
    if ! grep -q "xmodmap.*Xmodmap" "$XPROFILE_FILE" 2>/dev/null; then
        echo "Adding to $XPROFILE_FILE..."
        {
            echo ""
            echo "# Load custom key mappings"
            echo "[ -f ~/.Xmodmap ] && xmodmap ~/.Xmodmap"
        } >> "$XPROFILE_FILE"
        echo "✓ Added to .xprofile"
    else
        echo "✓ .xprofile already configured"
    fi

    # Note: .bashrc is managed by dotfiles setup script
    # X11 keymap loading is handled by .xinitrc and .xprofile
    echo "Note: .bashrc is managed by dotfiles setup - X11 keymap loading configured in startup files"
fi

echo ""
echo "Step 6: Applying X11 keymap for current session..."

# Apply xmodmap for current X11 session if available
if [ -n "$DISPLAY" ] && command -v xmodmap &> /dev/null; then
    echo "Applying X11 keymap for current session..."
    XMODMAP_FILE="$HOME/.Xmodmap"
    if [ -f "$XMODMAP_FILE" ]; then
        xmodmap "$XMODMAP_FILE"
        echo "✓ X11 keymap applied"
    else
        echo "⚠ .Xmodmap file not found"
    fi
else
    echo "⚠ Not in X11 session or xmodmap not available"
    echo "  Keymap will be applied when X11 starts"
fi

echo ""
echo "Step 7: Setting up systemd service for vconsole..."

# Create systemd service to ensure keymap is loaded on boot
SYSTEMD_SERVICE="/etc/systemd/system/caps-to-ctrl.service"

echo "Creating systemd service: $SYSTEMD_SERVICE"
# Use Japanese keymap if available, otherwise fall back to US keymap
KEYMAP_TO_USE="$CUSTOM_KEYMAP"
if [ -f "$JP106_KEYMAP" ]; then
    KEYMAP_TO_USE="$JP106_KEYMAP"
fi

sudo tee "$SYSTEMD_SERVICE" > /dev/null << EOF
[Unit]
Description=Load Caps Lock to Ctrl keymap
After=systemd-vconsole-setup.service
Before=getty@.service

[Service]
Type=oneshot
ExecStart=/usr/bin/loadkeys $KEYMAP_TO_USE
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Enable the service
echo "Enabling systemd service..."
sudo systemctl enable caps-to-ctrl.service
echo "✓ Systemd service created and enabled"

echo ""
echo "Caps Lock to Ctrl setup completed successfully!"
echo ""
echo "SUMMARY:"
echo "✓ Virtual console keymap configured (with Japanese support)"
echo "✓ X11 keymap configured"
echo "✓ /etc/default/keyboard configured with ctrl:nocaps option"
echo "✓ Automatic loading set up for both environments"
echo "✓ Systemd service created for boot-time loading"
echo ""
echo "IMPORTANT:"
echo "- Changes are applied to current session where possible"
echo "- Full effect will be visible after reboot"
echo "- Works in both virtual console (Ctrl+Alt+F1-F6) and graphical sessions"
echo "- To test: try using Caps Lock as Ctrl in terminal or text editor"
echo "================================"
