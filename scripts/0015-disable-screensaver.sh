#!/bin/bash

# Disable Screen Saver and Lock for GNOME and Cinnamon
# This script disables screen saver and screen lock to prevent interruptions during setup

echo "======================================="
echo "  Disable Screen Saver and Lock Script"
echo "  For GNOME and Cinnamon Desktop"
echo "======================================="
echo ""

# Backup directory for original settings
BACKUP_DIR="/tmp/manjaro-setup-screensaver-backup"
mkdir -p "$BACKUP_DIR"

# Detect desktop environment and session type
CURRENT_DESKTOP="${XDG_CURRENT_DESKTOP:-unknown}"
SESSION_TYPE="${XDG_SESSION_TYPE:-unknown}"

echo "Current desktop environment: $CURRENT_DESKTOP"
echo "Current session type: $SESSION_TYPE"
echo ""

# Check if we're in a graphical session
if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
    echo "No graphical session detected. Applying system-level settings only."

    # Mask systemd sleep targets
    if command -v systemctl &> /dev/null; then
        echo "Masking systemd sleep targets..."
        sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target 2>/dev/null || true
        echo "✓ System sleep targets masked"
    fi

    echo "Screen saver settings cannot be configured without a graphical session."
    echo "======================================="
    exit 0
fi

echo "Graphical session detected. Configuring screen saver settings..."

# Function to disable Cinnamon screensaver
disable_cinnamon_screensaver() {
    echo "Configuring Cinnamon screen saver settings..."

    # Backup current settings
    {
        echo "# Cinnamon screensaver backup - $(date)"
        gsettings get org.cinnamon.desktop.screensaver lock-enabled 2>/dev/null || echo "lock-enabled=UNAVAILABLE"
        gsettings get org.cinnamon.desktop.screensaver idle-activation-enabled 2>/dev/null || echo "idle-activation-enabled=UNAVAILABLE"
        gsettings get org.cinnamon.desktop.session idle-delay 2>/dev/null || echo "idle-delay=UNAVAILABLE"
        gsettings get org.cinnamon.settings-daemon.plugins.power sleep-inactive-ac-timeout 2>/dev/null || echo "sleep-inactive-ac-timeout=UNAVAILABLE"
    } > "$BACKUP_DIR/cinnamon_settings.backup"

    # Disable Cinnamon screensaver and lock
    echo "  Disabling screen lock..."
    gsettings set org.cinnamon.desktop.screensaver lock-enabled false

    echo "  Disabling idle activation..."
    gsettings set org.cinnamon.desktop.screensaver idle-activation-enabled false

    echo "  Setting long idle delay..."
    gsettings set org.cinnamon.desktop.session idle-delay 0

    echo "  Disabling power management sleep..."
    gsettings set org.cinnamon.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
    gsettings set org.cinnamon.settings-daemon.plugins.power sleep-inactive-battery-timeout 0

    echo "✓ Cinnamon screen saver and lock disabled"
}

# Function to disable GNOME screensaver
disable_gnome_screensaver() {
    echo "Configuring GNOME screen saver settings..."

    # Backup current settings
    {
        echo "# GNOME screensaver backup - $(date)"
        gsettings get org.gnome.desktop.screensaver lock-enabled 2>/dev/null || echo "lock-enabled=UNAVAILABLE"
        gsettings get org.gnome.desktop.screensaver idle-activation-enabled 2>/dev/null || echo "idle-activation-enabled=UNAVAILABLE"
        gsettings get org.gnome.desktop.session idle-delay 2>/dev/null || echo "idle-delay=UNAVAILABLE"
        gsettings get org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 2>/dev/null || echo "sleep-inactive-ac-timeout=UNAVAILABLE"
    } > "$BACKUP_DIR/gnome_settings.backup"

    # Disable GNOME screensaver and lock
    echo "  Disabling screen lock..."
    gsettings set org.gnome.desktop.screensaver lock-enabled false

    echo "  Disabling idle activation..."
    gsettings set org.gnome.desktop.screensaver idle-activation-enabled false

    echo "  Setting long idle delay..."
    gsettings set org.gnome.desktop.session idle-delay 0

    echo "  Disabling power management sleep..."
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 0

    echo "✓ GNOME screen saver and lock disabled"
}

# Function to disable Xscreensaver
disable_xscreensaver() {
    if command -v xscreensaver-command &> /dev/null; then
        echo "Disabling Xscreensaver..."

        # Kill xscreensaver if running
        xscreensaver-command -exit 2>/dev/null || true

        # Backup and modify .xscreensaver
        if [ -f "$HOME/.xscreensaver" ]; then
            cp "$HOME/.xscreensaver" "$BACKUP_DIR/xscreensaver.backup"
        fi

        # Create or modify .xscreensaver to disable
        cat > "$HOME/.xscreensaver" << 'EOF'
# Temporarily disabled for system setup
mode: off
timeout: 0
lock: False
lockTimeout: 0
EOF
        echo "✓ Xscreensaver disabled"
    fi
}

# Apply settings based on desktop environment
case "$CURRENT_DESKTOP" in
    *GNOME*|*gnome*)
        disable_gnome_screensaver
        ;;
    *Cinnamon*|*cinnamon*|*CINNAMON*)
        disable_cinnamon_screensaver
        ;;
    *)
        echo "Unknown or unsupported desktop environment: $CURRENT_DESKTOP"
        echo "Attempting to disable common screensaver systems..."

        # Try both GNOME and Cinnamon settings
        if gsettings list-schemas | grep -q "org.gnome.desktop.screensaver"; then
            disable_gnome_screensaver
        fi

        if gsettings list-schemas | grep -q "org.cinnamon.desktop.screensaver"; then
            disable_cinnamon_screensaver
        fi
        ;;
esac

# Always try to disable Xscreensaver as well
disable_xscreensaver

# Disable systemd sleep targets
echo ""
echo "Disabling system sleep targets..."
if command -v systemctl &> /dev/null; then
    # Backup current state
    {
        echo "# systemd sleep targets backup - $(date)"
        systemctl is-masked sleep.target 2>/dev/null || echo "sleep.target=not-masked"
        systemctl is-masked suspend.target 2>/dev/null || echo "suspend.target=not-masked"
        systemctl is-masked hibernate.target 2>/dev/null || echo "hibernate.target=not-masked"
        systemctl is-masked hybrid-sleep.target 2>/dev/null || echo "hybrid-sleep.target=not-masked"
    } > "$BACKUP_DIR/systemd_sleep.backup"

    # Mask sleep targets
    sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target 2>/dev/null || true
    echo "✓ System sleep targets masked"
fi

# Force immediate application of settings
echo ""
echo "Applying settings immediately..."

# Kill any running screensaver processes
pkill -f "gnome-screensaver" 2>/dev/null || true
pkill -f "cinnamon-screensaver" 2>/dev/null || true
pkill -f "xscreensaver" 2>/dev/null || true

# Reset idle timer
if command -v xset &> /dev/null && [ -n "$DISPLAY" ]; then
    echo "Resetting X11 idle timer..."
    xset s off 2>/dev/null || true
    xset s noblank 2>/dev/null || true
    xset -dpms 2>/dev/null || true
    echo "✓ X11 power management disabled"
fi

echo ""
echo "======================================="
echo "  Screen Saver and Lock Disabled"
echo "======================================="
echo ""
echo "✓ Screen saver and lock have been disabled during setup"
echo "✓ Settings backed up to: $BACKUP_DIR"
echo "✓ X11 power management disabled"
echo "✓ System sleep targets masked"
echo ""
echo "Note: Settings will be restored after setup completion"
echo ""
