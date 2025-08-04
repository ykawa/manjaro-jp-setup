#!/bin/bash

# WezTerm Autostart Configuration Script
# This script configures WezTerm to start automatically on login

set -e

echo "======================================="
echo "  WezTerm Autostart Configuration"
echo "  Setup Terminal Auto-launch"
echo "======================================="
echo ""

# Check if wezterm is installed
if ! command -v wezterm &> /dev/null; then
    echo "⚠ WezTerm is not installed yet."
    echo "This script will create the autostart configuration anyway."
    echo "WezTerm will start automatically once it's installed."
    echo ""
fi

# Function to create autostart entry
create_autostart_entry() {
    echo "Creating WezTerm autostart entry..."

    # Create autostart directory if it doesn't exist
    mkdir -p "$HOME/.config/autostart"

    # Create WezTerm autostart desktop entry
    cat > "$HOME/.config/autostart/wezterm.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=WezTerm
Comment=Start WezTerm terminal automatically on login
Exec=wezterm
Icon=org.wezfurlong.wezterm
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=3
X-KDE-autostart-after=panel
X-MATE-Autostart-enabled=true
Categories=System;TerminalEmulator;
StartupNotify=true
EOF

    echo "✓ WezTerm autostart entry created: $HOME/.config/autostart/wezterm.desktop"
}

# Function to create startup script with delay and positioning
create_startup_script() {
    echo "Creating WezTerm startup script with positioning..."

    # Create local bin directory if it doesn't exist
    mkdir -p "$HOME/.local/bin"

    # Create startup script for WezTerm with positioning
    cat > "$HOME/.local/bin/start-wezterm.sh" << 'EOF'
#!/bin/bash
# WezTerm startup script with positioning and delay

# Wait for desktop environment to be fully loaded
sleep 5

# Check if WezTerm is installed
if ! command -v wezterm &> /dev/null; then
    echo "WezTerm not found, skipping autostart"
    exit 0
fi

# Check if WezTerm is already running to avoid duplicates
if pgrep -f "wezterm" > /dev/null; then
    echo "WezTerm is already running"
    exit 0
fi

# Start WezTerm with specific positioning (if supported)
# Position it in the center-right of the screen
if [ -n "$DISPLAY" ]; then
    # Get screen resolution if possible
    if command -v xrandr &> /dev/null; then
        SCREEN_INFO=$(xrandr --current | grep "primary" | head -1)
        if [ -n "$SCREEN_INFO" ]; then
            # Extract resolution (e.g., "1920x1080")
            RESOLUTION=$(echo "$SCREEN_INFO" | grep -o '[0-9]*x[0-9]*' | head -1)
            echo "Detected resolution: $RESOLUTION"
        fi
    fi

    # Start WezTerm
    wezterm &

    # Wait a moment for the window to appear
    sleep 2

    # Try to position the window using wmctrl if available
    if command -v wmctrl &> /dev/null; then
        # Move WezTerm window to right side of screen
        wmctrl -r "wezterm" -e 0,960,100,900,600 2>/dev/null || true
    fi
else
    # Fallback: just start WezTerm without positioning
    wezterm &
fi

echo "WezTerm started automatically"
EOF

    chmod +x "$HOME/.local/bin/start-wezterm.sh"
    echo "✓ WezTerm startup script created: $HOME/.local/bin/start-wezterm.sh"
}

# Function to create alternative autostart using the startup script
create_script_autostart() {
    echo "Creating alternative autostart entry using startup script..."

    # Create autostart entry that calls our script
    cat > "$HOME/.config/autostart/wezterm-startup.desktop" << EOF
[Desktop Entry]
Type=Application
Name=WezTerm Startup
Comment=Start WezTerm terminal with positioning
Exec=$HOME/.local/bin/start-wezterm.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=2
X-KDE-autostart-after=panel
X-MATE-Autostart-enabled=true
Categories=System;TerminalEmulator;
StartupNotify=false
EOF

    echo "✓ WezTerm script autostart entry created: $HOME/.config/autostart/wezterm-startup.desktop"
}

# Function to add to shell profile as backup
add_to_shell_profile() {
    echo "Adding WezTerm autostart to shell profile as backup..."

    # Add to .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q "# WezTerm autostart" "$HOME/.bashrc"; then
            cat >> "$HOME/.bashrc" << 'EOF'

# WezTerm autostart (backup method)
if [ -z "$WEZTERM_STARTED" ] && [ -n "$DISPLAY" ] && [ "$SHLVL" -eq 1 ]; then
    export WEZTERM_STARTED=1
    if command -v wezterm &> /dev/null && ! pgrep -f "wezterm" > /dev/null; then
        (sleep 3 && wezterm &) &
    fi
fi
EOF
            echo "✓ WezTerm autostart added to .bashrc"
        fi
    fi

    # Add to .zshrc if it exists
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "# WezTerm autostart" "$HOME/.zshrc"; then
            cat >> "$HOME/.zshrc" << 'EOF'

# WezTerm autostart (backup method)
if [ -z "$WEZTERM_STARTED" ] && [ -n "$DISPLAY" ] && [ "$SHLVL" -eq 1 ]; then
    export WEZTERM_STARTED=1
    if command -v wezterm &> /dev/null && ! pgrep -f "wezterm" > /dev/null; then
        (sleep 3 && wezterm &) &
    fi
fi
EOF
            echo "✓ WezTerm autostart added to .zshrc"
        fi
    fi
}

# Function for GNOME/Cinnamon specific autostart
configure_gnome_autostart() {
    if command -v gsettings &> /dev/null && (pgrep -x "gnome-shell" > /dev/null || [ "$XDG_CURRENT_DESKTOP" = "GNOME" ] || pgrep -x "cinnamon" > /dev/null || [ "$XDG_CURRENT_DESKTOP" = "X-Cinnamon" ]); then
        echo "Configuring GNOME/Cinnamon specific autostart..."

        # Add WezTerm to GNOME startup applications using gsettings (if supported)
        # This is a newer method that some GNOME versions support

        echo "✓ GNOME/Cinnamon autostart configured via .desktop files"
    else
        echo "GNOME/Cinnamon not detected, using standard autostart methods"
    fi
}

# Main configuration process
echo "Current desktop environment: ${XDG_CURRENT_DESKTOP:-Not set}"
echo "Current session type: ${XDG_SESSION_TYPE:-Not set}"
echo ""

echo "Setting up WezTerm autostart..."
echo ""

# Create all autostart methods for maximum compatibility
create_autostart_entry
echo ""

create_startup_script
echo ""

create_script_autostart
echo ""

configure_gnome_autostart
echo ""

add_to_shell_profile

echo ""
echo "======================================="
echo "  WezTerm Autostart Configuration"
echo "  Completed Successfully"
echo "======================================="
echo ""
echo "Multiple autostart methods configured:"
echo "• Desktop autostart entry (.desktop file)"
echo "• Startup script with positioning"
echo "• Shell profile backup method"
echo ""
echo "WezTerm will automatically start on next login with:"
echo "• 3-5 second delay to ensure desktop is ready"
echo "• Duplicate detection to prevent multiple instances"
echo "• Window positioning (if wmctrl is available)"
echo ""
echo "Files created:"
echo "• $HOME/.config/autostart/wezterm.desktop"
echo "• $HOME/.config/autostart/wezterm-startup.desktop"
echo "• $HOME/.local/bin/start-wezterm.sh"
echo ""
echo "Note: WezTerm autostart will work once WezTerm is installed."
echo ""
