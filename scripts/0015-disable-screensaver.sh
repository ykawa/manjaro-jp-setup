#!/bin/bash

# Disable Screen Saver and Lock for GNOME and Cinnamon
# This script disables screen saver and screen lock to prevent interruptions during setup
# Settings are backed up to /tmp for restoration after setup completion

set -e

echo "======================================="
echo "  Disable Screen Saver and Lock Script"
echo "  For GNOME and Cinnamon Desktop"
echo "======================================="
echo ""

# Backup directory for original settings
BACKUP_DIR="/tmp/manjaro-setup-screensaver-backup"
mkdir -p "$BACKUP_DIR"

echo "Backing up current settings to: $BACKUP_DIR"

# Function to backup and disable GNOME screen saver and lock
disable_gnome_screensaver() {
    echo "Disabling GNOME screen saver and lock..."

    # Check if GNOME is running
    if pgrep -x "gnome-shell" > /dev/null || [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; then
        echo "GNOME detected, backing up and configuring settings..."

        # Backup current settings
        {
            echo "# GNOME screensaver backup - $(date)"
            echo "GNOME_SCREENSAVER_IDLE_ACTIVATION=$(gsettings get org.gnome.desktop.screensaver idle-activation-enabled 2>/dev/null || echo 'true')"
            echo "GNOME_SCREENSAVER_LOCK_ENABLED=$(gsettings get org.gnome.desktop.screensaver lock-enabled 2>/dev/null || echo 'true')"
            echo "GNOME_POWER_SLEEP_AC=$(gsettings get org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 2>/dev/null || echo \"'suspend'\")"
            echo "GNOME_POWER_SLEEP_BATTERY=$(gsettings get org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 2>/dev/null || echo \"'suspend'\")"
            echo "GNOME_SESSION_IDLE_DELAY=$(gsettings get org.gnome.desktop.session idle-delay 2>/dev/null || echo '300')"
        } > "$BACKUP_DIR/gnome_settings.backup"

        # Disable screen saver
        gsettings set org.gnome.desktop.screensaver idle-activation-enabled false
        gsettings set org.gnome.desktop.screensaver lock-enabled false

        # Disable automatic suspend
        gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
        gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'

        # Set screen blank timeout to never (0)
        gsettings set org.gnome.desktop.session idle-delay 0

        echo "✓ GNOME settings backed up and screen saver disabled"
    else
        echo "GNOME not detected, skipping GNOME configuration"
    fi
}

# Function to backup and disable Cinnamon screen saver and lock
disable_cinnamon_screensaver() {
    echo "Disabling Cinnamon screen saver and lock..."

    # Check if Cinnamon is running
    if pgrep -x "cinnamon" > /dev/null || [ "$XDG_CURRENT_DESKTOP" = "X-Cinnamon" ]; then
        echo "Cinnamon detected, backing up and configuring settings..."

        # Backup current settings
        {
            echo "# Cinnamon screensaver backup - $(date)"
            echo "CINNAMON_SCREENSAVER_IDLE_ACTIVATION=$(gsettings get org.cinnamon.desktop.screensaver idle-activation-enabled 2>/dev/null || echo 'true')"
            echo "CINNAMON_SCREENSAVER_LOCK_ENABLED=$(gsettings get org.cinnamon.desktop.screensaver lock-enabled 2>/dev/null || echo 'true')"
            echo "CINNAMON_POWER_SLEEP_AC=$(gsettings get org.cinnamon.settings-daemon.plugins.power sleep-inactive-ac-type 2>/dev/null || echo \"'suspend'\")"
            echo "CINNAMON_POWER_SLEEP_BATTERY=$(gsettings get org.cinnamon.settings-daemon.plugins.power sleep-inactive-battery-type 2>/dev/null || echo \"'suspend'\")"
            echo "CINNAMON_SESSION_IDLE_DELAY=$(gsettings get org.cinnamon.desktop.session idle-delay 2>/dev/null || echo '300')"
            echo "CINNAMON_SCREENSAVER_NAME=$(gsettings get org.cinnamon.desktop.screensaver screensaver-name 2>/dev/null || echo \"'blank-only'\")"
        } > "$BACKUP_DIR/cinnamon_settings.backup"

        # Disable screen saver
        gsettings set org.cinnamon.desktop.screensaver idle-activation-enabled false
        gsettings set org.cinnamon.desktop.screensaver lock-enabled false

        # Disable automatic suspend
        gsettings set org.cinnamon.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
        gsettings set org.cinnamon.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'

        # Set screen blank timeout to never (0)
        gsettings set org.cinnamon.desktop.session idle-delay 0

        # Additional Cinnamon-specific settings
        gsettings set org.cinnamon.desktop.screensaver screensaver-name ""

        echo "✓ Cinnamon settings backed up and screen saver disabled"
    else
        echo "Cinnamon not detected, skipping Cinnamon configuration"
    fi
}

# Function to backup and disable Xscreensaver if installed
disable_xscreensaver() {
    echo "Checking for Xscreensaver..."

    if command -v xscreensaver &> /dev/null; then
        echo "Xscreensaver detected, backing up and disabling..."

        # Backup existing .xscreensaver if it exists
        if [ -f "$HOME/.xscreensaver" ]; then
            cp "$HOME/.xscreensaver" "$BACKUP_DIR/xscreensaver.backup"
            echo "✓ Xscreensaver config backed up"
        else
            echo "XSCREENSAVER_NOT_CONFIGURED=true" > "$BACKUP_DIR/xscreensaver.backup"
        fi

        # Kill any running xscreensaver processes
        pkill -f xscreensaver || true

        # Create/update .xscreensaver config to disable
        cat > "$HOME/.xscreensaver" << 'EOF'
# XScreenSaver Preferences
# Disabled for setup process

mode: off
timeout: 0
cycle: 0
lock: False
lockTimeout: 0
dpmsEnabled: False
dpmsQuickOff: False
dpmsStandby: 0
dpmsSuspend: 0
dpmsOff: 0
EOF

        echo "✓ Xscreensaver backed up and disabled"
    else
        echo "Xscreensaver not found, skipping"
    fi
}

# Check if we're in a graphical session
if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
    echo "No graphical session detected. Screen saver settings will be applied when GUI is available."
    exit 0
fi

echo "Current desktop environment: ${XDG_CURRENT_DESKTOP:-Not set}"
echo "Current session type: ${XDG_SESSION_TYPE:-Not set}"
echo ""

# Apply configurations based on detected desktop environment
disable_gnome_screensaver
echo ""
disable_cinnamon_screensaver
echo ""
disable_xscreensaver

echo ""
echo "Additional system-wide power management settings..."

# Backup systemd sleep status and disable sleep/suspend
if command -v systemctl &> /dev/null; then
    echo "Temporarily disabling system sleep/suspend..."

    # Backup systemd sleep target status
    {
        echo "# systemd sleep targets backup - $(date)"
        echo "SLEEP_TARGET_MASKED=$(systemctl is-masked sleep.target 2>/dev/null || echo 'false')"
        echo "SUSPEND_TARGET_MASKED=$(systemctl is-masked suspend.target 2>/dev/null || echo 'false')"
        echo "HIBERNATE_TARGET_MASKED=$(systemctl is-masked hibernate.target 2>/dev/null || echo 'false')"
        echo "HYBRID_SLEEP_TARGET_MASKED=$(systemctl is-masked hybrid-sleep.target 2>/dev/null || echo 'false')"
    } > "$BACKUP_DIR/systemd_sleep.backup"

    # Mask sleep targets to prevent accidental suspend during setup
    sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target || echo "Warning: Could not mask sleep targets"

    echo "✓ System sleep targets backed up and masked"
fi

echo ""
echo "======================================="
echo "  Screen Saver and Lock Disabled"
echo "  Settings backed up and applied"
echo "======================================="
echo ""
echo "Backup location: $BACKUP_DIR"
echo "Note: Settings will be restored after setup completion."
echo ""
