#!/bin/bash

# Restore Screen Saver and Lock Settings
# This script restores the original screen saver and lock settings that were backed up
# during the setup process

set -e

echo "======================================="
echo "  Restore Screen Saver and Lock Script"
echo "  For GNOME and Cinnamon Desktop"
echo "======================================="
echo ""

# Backup directory for original settings
BACKUP_DIR="/tmp/manjaro-setup-screensaver-backup"

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo "No backup directory found at: $BACKUP_DIR"
    echo "Screen saver settings were likely not modified during setup."
    echo "Nothing to restore."
    exit 0
fi

echo "Restoring settings from: $BACKUP_DIR"

# Function to restore GNOME screen saver and lock settings
restore_gnome_screensaver() {
    local backup_file="$BACKUP_DIR/gnome_settings.backup"

    if [ ! -f "$backup_file" ]; then
        echo "No GNOME backup found, skipping GNOME restoration"
        return 0
    fi

    echo "Restoring GNOME screen saver and lock settings..."

    # Check if GNOME is running
    if pgrep -x "gnome-shell" > /dev/null || [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; then
        echo "GNOME detected, restoring settings..."

        # Read the backup file safely to get the original values
        declare -A gnome_settings
        while IFS='=' read -r key value; do
            case "$key" in
                "GNOME_SCREENSAVER_IDLE_ACTIVATION") gnome_settings[idle_activation]="$value" ;;
                "GNOME_SCREENSAVER_LOCK_ENABLED") gnome_settings[lock_enabled]="$value" ;;
                "GNOME_POWER_SLEEP_AC") gnome_settings[sleep_ac]="$value" ;;
                "GNOME_POWER_SLEEP_BATTERY") gnome_settings[sleep_battery]="$value" ;;
                "GNOME_SESSION_IDLE_DELAY") gnome_settings[idle_delay]="$value" ;;
            esac
        done < <(grep -E "^[A-Z_]+=[^#]*$" "$backup_file" 2>/dev/null || true)

        # Restore screen saver settings
        if [ -n "${gnome_settings[idle_activation]}" ]; then
            gsettings set org.gnome.desktop.screensaver idle-activation-enabled "${gnome_settings[idle_activation]}"
        fi

        if [ -n "${gnome_settings[lock_enabled]}" ]; then
            gsettings set org.gnome.desktop.screensaver lock-enabled "${gnome_settings[lock_enabled]}"
        fi

        # Restore power management settings
        if [ -n "${gnome_settings[sleep_ac]}" ]; then
            gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type "${gnome_settings[sleep_ac]}"
        fi

        if [ -n "${gnome_settings[sleep_battery]}" ]; then
            gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type "${gnome_settings[sleep_battery]}"
        fi

        # Restore session idle delay
        if [ -n "${gnome_settings[idle_delay]}" ]; then
            gsettings set org.gnome.desktop.session idle-delay "${gnome_settings[idle_delay]}"
        fi

        echo "✓ GNOME screen saver and lock settings restored"
    else
        echo "GNOME not detected, skipping GNOME restoration"
    fi
}

# Function to restore Cinnamon screen saver and lock settings
restore_cinnamon_screensaver() {
    local backup_file="$BACKUP_DIR/cinnamon_settings.backup"

    if [ ! -f "$backup_file" ]; then
        echo "No Cinnamon backup found, skipping Cinnamon restoration"
        return 0
    fi

    echo "Restoring Cinnamon screen saver and lock settings..."

    # Check if Cinnamon is running
    if pgrep -x "cinnamon" > /dev/null || [ "$XDG_CURRENT_DESKTOP" = "X-Cinnamon" ]; then
        echo "Cinnamon detected, restoring settings..."

        # Read the backup file safely to get the original values
        declare -A cinnamon_settings
        while IFS='=' read -r key value; do
            case "$key" in
                "CINNAMON_SCREENSAVER_IDLE_ACTIVATION") cinnamon_settings[idle_activation]="$value" ;;
                "CINNAMON_SCREENSAVER_LOCK_ENABLED") cinnamon_settings[lock_enabled]="$value" ;;
                "CINNAMON_POWER_SLEEP_AC") cinnamon_settings[sleep_ac]="$value" ;;
                "CINNAMON_POWER_SLEEP_BATTERY") cinnamon_settings[sleep_battery]="$value" ;;
                "CINNAMON_SESSION_IDLE_DELAY") cinnamon_settings[idle_delay]="$value" ;;
                "CINNAMON_SCREENSAVER_NAME") cinnamon_settings[screensaver_name]="$value" ;;
            esac
        done < <(grep -E "^[A-Z_]+=[^#]*$" "$backup_file" 2>/dev/null || true)

        # Restore screen saver settings
        if [ -n "${cinnamon_settings[idle_activation]}" ]; then
            gsettings set org.cinnamon.desktop.screensaver idle-activation-enabled "${cinnamon_settings[idle_activation]}"
        fi

        if [ -n "${cinnamon_settings[lock_enabled]}" ]; then
            gsettings set org.cinnamon.desktop.screensaver lock-enabled "${cinnamon_settings[lock_enabled]}"
        fi

        # Restore power management settings
        if [ -n "${cinnamon_settings[sleep_ac]}" ]; then
            gsettings set org.cinnamon.settings-daemon.plugins.power sleep-inactive-ac-type "${cinnamon_settings[sleep_ac]}"
        fi

        if [ -n "${cinnamon_settings[sleep_battery]}" ]; then
            gsettings set org.cinnamon.settings-daemon.plugins.power sleep-inactive-battery-type "${cinnamon_settings[sleep_battery]}"
        fi

        # Restore session idle delay
        if [ -n "${cinnamon_settings[idle_delay]}" ]; then
            gsettings set org.cinnamon.desktop.session idle-delay "${cinnamon_settings[idle_delay]}"
        fi

        # Restore screensaver name
        if [ -n "${cinnamon_settings[screensaver_name]}" ]; then
            gsettings set org.cinnamon.desktop.screensaver screensaver-name "${cinnamon_settings[screensaver_name]}"
        fi

        echo "✓ Cinnamon screen saver and lock settings restored"
    else
        echo "Cinnamon not detected, skipping Cinnamon restoration"
    fi
}

# Function to restore Xscreensaver settings
restore_xscreensaver() {
    local backup_file="$BACKUP_DIR/xscreensaver.backup"

    if [ ! -f "$backup_file" ]; then
        echo "No Xscreensaver backup found, skipping Xscreensaver restoration"
        return 0
    fi

    echo "Restoring Xscreensaver settings..."

    if command -v xscreensaver &> /dev/null; then
        echo "Xscreensaver detected, restoring settings..."

        # Check if it was originally not configured
        if grep -q "XSCREENSAVER_NOT_CONFIGURED=true" "$backup_file"; then
            echo "Xscreensaver was not originally configured, removing setup config..."
            rm -f "$HOME/.xscreensaver"
        else
            # Restore original configuration
            cp "$backup_file" "$HOME/.xscreensaver"
            echo "✓ Xscreensaver configuration restored"
        fi

        echo "✓ Xscreensaver settings restored"
    else
        echo "Xscreensaver not found, skipping Xscreensaver restoration"
    fi
}

# Function to restore systemd sleep targets
restore_systemd_sleep() {
    local backup_file="$BACKUP_DIR/systemd_sleep.backup"

    if [ ! -f "$backup_file" ]; then
        echo "No systemd sleep backup found, skipping systemd restoration"
        return 0
    fi

    echo "Restoring systemd sleep targets..."

    if command -v systemctl &> /dev/null; then
        # Read the backup file safely to get the original values
        declare -A systemd_settings
        while IFS='=' read -r key value; do
            case "$key" in
                "SLEEP_TARGET_MASKED") systemd_settings[sleep_masked]="$value" ;;
                "SUSPEND_TARGET_MASKED") systemd_settings[suspend_masked]="$value" ;;
                "HIBERNATE_TARGET_MASKED") systemd_settings[hibernate_masked]="$value" ;;
                "HYBRID_SLEEP_TARGET_MASKED") systemd_settings[hybrid_sleep_masked]="$value" ;;
            esac
        done < <(grep -E "^[A-Z_]+=[^#]*$" "$backup_file" 2>/dev/null || true)

        # Restore sleep targets based on original state
        if [ "${systemd_settings[sleep_masked]}" = "false" ]; then
            sudo systemctl unmask sleep.target || echo "Warning: Could not unmask sleep.target"
        fi

        if [ "${systemd_settings[suspend_masked]}" = "false" ]; then
            sudo systemctl unmask suspend.target || echo "Warning: Could not unmask suspend.target"
        fi

        if [ "${systemd_settings[hibernate_masked]}" = "false" ]; then
            sudo systemctl unmask hibernate.target || echo "Warning: Could not unmask hibernate.target"
        fi

        if [ "${systemd_settings[hybrid_sleep_masked]}" = "false" ]; then
            sudo systemctl unmask hybrid-sleep.target || echo "Warning: Could not unmask hybrid-sleep.target"
        fi

        echo "✓ systemd sleep targets restored"
    else
        echo "systemctl not found, skipping systemd restoration"
    fi
}

# Check if we're in a graphical session
if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
    echo "No graphical session detected. Restoring system-level settings only."
    restore_systemd_sleep
    exit 0
fi

echo "Current desktop environment: ${XDG_CURRENT_DESKTOP:-Not set}"
echo "Current session type: ${XDG_SESSION_TYPE:-Not set}"
echo ""

# Restore configurations based on detected desktop environment
restore_gnome_screensaver
echo ""
restore_cinnamon_screensaver
echo ""
restore_xscreensaver

echo ""
echo "Restoring system-wide power management settings..."
restore_systemd_sleep

echo ""
echo "Cleaning up backup files..."
rm -rf "$BACKUP_DIR"

echo ""
echo "======================================="
echo "  Screen Saver and Lock Settings"
echo "  Restored Successfully"
echo "======================================="
echo ""
echo "Your original screen saver and power management settings have been restored."
echo "Backup files have been cleaned up."
echo ""
