#!/bin/bash

# System Configuration Script for Manjaro Linux
# Configures various system settings and preferences

set -e

echo "================================"
echo "  System Configuration Script"
echo "  Manjaro Linux Setup"
echo "================================"
echo ""

# Disable Manjaro Hello
echo "Step 1: Disabling Manjaro Hello..."
if [ -f ~/.config/autostart/manjaro-hello.desktop ]; then
    rm ~/.config/autostart/manjaro-hello.desktop
fi
sudo systemctl disable manjaro-hello || true

# Configure HandleLidSwitch
echo "Step 2: Configuring lid switch behavior..."
sudo sed -i 's/^#HandleLidSwitch=.*/HandleLidSwitch=lock/' /etc/systemd/logind.conf
sudo sed -i 's/^HandleLidSwitch=.*/HandleLidSwitch=lock/' /etc/systemd/logind.conf

# Configure systemd timeout
echo "Step 3: Configuring systemd timeout..."
if ! grep -q "DefaultTimeoutStopSec=10s" /etc/systemd/system.conf; then
    sudo sed -i 's/^#DefaultTimeoutStopSec=.*/DefaultTimeoutStopSec=10s/' /etc/systemd/system.conf
fi

# Configure keyboard repeat settings
echo "Step 4: Configuring keyboard repeat settings..."
gsettings set org.cinnamon.desktop.peripherals.keyboard repeat true
gsettings set org.cinnamon.desktop.peripherals.keyboard delay 200
gsettings set org.cinnamon.desktop.peripherals.keyboard repeat-interval 18

# Rename Japanese directories to English
echo "Step 5: Renaming Japanese directories to English..."
if [ -d "$HOME/画像" ]; then
    mv "$HOME/画像" "$HOME/Pictures" 2>/dev/null || true
fi
if [ -d "$HOME/テンプレート" ]; then
    mv "$HOME/テンプレート" "$HOME/Templates" 2>/dev/null || true
fi
if [ -d "$HOME/ダウンロード" ]; then
    mv "$HOME/ダウンロード" "$HOME/Downloads" 2>/dev/null || true
fi
if [ -d "$HOME/ドキュメント" ]; then
    mv "$HOME/ドキュメント" "$HOME/Documents" 2>/dev/null || true
fi
if [ -d "$HOME/デスクトップ" ]; then
    mv "$HOME/デスクトップ" "$HOME/Desktop" 2>/dev/null || true
fi
if [ -d "$HOME/ビデオ" ]; then
    mv "$HOME/ビデオ" "$HOME/Videos" 2>/dev/null || true
fi
if [ -d "$HOME/公開" ]; then
    mv "$HOME/公開" "$HOME/Public" 2>/dev/null || true
fi
if [ -d "$HOME/音楽" ]; then
    mv "$HOME/音楽" "$HOME/Music" 2>/dev/null || true
fi

# Update XDG user directories
echo "Updating XDG user directories..."
LANG=C xdg-user-dirs-update --force

# Fix Nemo bookmarks to use English directories
echo "Updating Nemo bookmarks to use English directories..."
NEMO_BOOKMARKS="$HOME/.config/gtk-3.0/bookmarks"

if [ -f "$NEMO_BOOKMARKS" ]; then
    # Backup original bookmarks
    cp "$NEMO_BOOKMARKS" "$NEMO_BOOKMARKS.backup.$(date +%Y%m%d_%H%M%S)"

    # Replace Japanese directory paths with English ones (both regular and URL-encoded)
    # URL-encoded Japanese directory names:
    # %E3%83%89%E3%82%AD%E3%83%A5%E3%83%A1%E3%83%B3%E3%83%88 = ドキュメント (Documents)
    # %E9%9F%B3%E6%A5%BD = 音楽 (Music)
    # %E7%94%BB%E5%83%8F = 画像 (Pictures)
    # %E3%83%93%E3%83%87%E3%82%AA = ビデオ (Videos)
    # %E3%83%80%E3%82%A6%E3%83%B3%E3%83%AD%E3%83%BC%E3%83%89 = ダウンロード (Downloads)
    # %E3%83%87%E3%82%B9%E3%82%AF%E3%83%88%E3%83%83%E3%83%97 = デスクトップ (Desktop)
    # %E5%85%AC%E9%96%8B = 公開 (Public)
    # %E3%83%86%E3%83%B3%E3%83%97%E3%83%AC%E3%83%BC%E3%83%88 = テンプレート (Templates)

    # Replace URL-encoded Japanese paths
    sed -i 's|file://'"$HOME"'/%E3%83%89%E3%82%AD%E3%83%A5%E3%83%A1%E3%83%B3%E3%83%88|file://'"$HOME"'/Documents|g' "$NEMO_BOOKMARKS"
    sed -i 's|file://'"$HOME"'/%E9%9F%B3%E6%A5%BD|file://'"$HOME"'/Music|g' "$NEMO_BOOKMARKS"
    sed -i 's|file://'"$HOME"'/%E7%94%BB%E5%83%8F|file://'"$HOME"'/Pictures|g' "$NEMO_BOOKMARKS"
    sed -i 's|file://'"$HOME"'/%E3%83%93%E3%83%87%E3%82%AA|file://'"$HOME"'/Videos|g' "$NEMO_BOOKMARKS"
    sed -i 's|file://'"$HOME"'/%E3%83%80%E3%82%A6%E3%83%B3%E3%83%AD%E3%83%BC%E3%83%89|file://'"$HOME"'/Downloads|g' "$NEMO_BOOKMARKS"
    sed -i 's|file://'"$HOME"'/%E3%83%87%E3%82%B9%E3%82%AF%E3%83%88%E3%83%83%E3%83%97|file://'"$HOME"'/Desktop|g' "$NEMO_BOOKMARKS"
    sed -i 's|file://'"$HOME"'/%E5%85%AC%E9%96%8B|file://'"$HOME"'/Public|g' "$NEMO_BOOKMARKS"
    sed -i 's|file://'"$HOME"'/%E3%83%86%E3%83%B3%E3%83%97%E3%83%AC%E3%83%BC%E3%83%88|file://'"$HOME"'/Templates|g' "$NEMO_BOOKMARKS"

    # デスクトップ は置換対象が無い場合があるので置換対象が無い場合は先頭に追加する
    if ! grep -q "file://${HOME}/Desktop" "$NEMO_BOOKMARKS"; then
        sed -i '1i file://'"$HOME"'/Desktop Desktop' "$NEMO_BOOKMARKS"
    fi

    # Also handle Desktop specific encoding if different
    # %E3%83%87%E3%82%B9%E3%82%AF%E3%83%88%E3%83%83%E3%83%97 should be Desktop but let me add more patterns
    sed -i 's|file://'"$HOME"'/Desktop[^[:space:]]*|file://'"$HOME"'/Desktop|g' "$NEMO_BOOKMARKS"

    # Also replace non-encoded Japanese paths (fallback)
    sed -i 's|file://'"$HOME"'/デスクトップ|file://'"$HOME"'/Desktop|g' "$NEMO_BOOKMARKS"
    sed -i 's|file://'"$HOME"'/ダウンロード|file://'"$HOME"'/Downloads|g' "$NEMO_BOOKMARKS"
    sed -i 's|file://'"$HOME"'/ドキュメント|file://'"$HOME"'/Documents|g' "$NEMO_BOOKMARKS"
    sed -i 's|file://'"$HOME"'/画像|file://'"$HOME"'/Pictures|g' "$NEMO_BOOKMARKS"
    sed -i 's|file://'"$HOME"'/音楽|file://'"$HOME"'/Music|g' "$NEMO_BOOKMARKS"
    sed -i 's|file://'"$HOME"'/ビデオ|file://'"$HOME"'/Videos|g' "$NEMO_BOOKMARKS"
    sed -i 's|file://'"$HOME"'/公開|file://'"$HOME"'/Public|g' "$NEMO_BOOKMARKS"
    sed -i 's|file://'"$HOME"'/テンプレート|file://'"$HOME"'/Templates|g' "$NEMO_BOOKMARKS"

    echo "✓ Nemo bookmarks updated to use English directories"
else
    echo "Nemo bookmarks file not found, creating with English directories..."
    mkdir -p "$(dirname "$NEMO_BOOKMARKS")"
    cat > "$NEMO_BOOKMARKS" << EOF
file://$HOME/Desktop Desktop
file://$HOME/Downloads Downloads
file://$HOME/Documents Documents
file://$HOME/Pictures Pictures
file://$HOME/Music Music
file://$HOME/Videos Videos
file://$HOME/Public Public
file://$HOME/Templates Templates
EOF
    echo "✓ Nemo bookmarks created with English directories"
fi

# Configure autologin for tty1-3
echo "Step 6: Configuring autologin for tty1-3..."
sudo mkdir -p /etc/systemd/system/getty@tty{1,2,3}.service.d

cat << EOF | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $USER --noclear %I \$TERM
EOF

cat << EOF | sudo tee /etc/systemd/system/getty@tty2.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $USER --noclear %I \$TERM
EOF

cat << EOF | sudo tee /etc/systemd/system/getty@tty3.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $USER --noclear %I \$TERM
EOF

echo ""
echo "Step 7: Disabling Cinnamon workspace functionality..."

# Disable Cinnamon workspace switching
if command -v gsettings >/dev/null 2>&1; then
    echo "Configuring Cinnamon workspace settings..."

    # Fix number of workspaces to 1
    gsettings set org.cinnamon.desktop.wm.preferences num-workspaces 1
    gsettings set org.cinnamon.muffin dynamic-workspaces false

    # Remove workspace switcher from panel
    echo "Removing workspace switcher from panel..."
    enabled=$(gsettings get org.cinnamon enabled-applets)
    echo "Current applets: $enabled"

    # Remove any applet entry that contains 'workspace-switcher@cinnamon.org'
    # Handle multiple removal patterns and clean up commas
    new=$(echo "$enabled" | \
        sed "s/'[^']*workspace-switcher@cinnamon.org[^']*',\?//g" | \
        sed "s/,\s*,/,/g" | \
        sed "s/\[\s*,/[/g" | \
        sed "s/,\s*]/]/g" | \
        sed "s/,\s*\]/]/g")

    echo "Updated applets: $new"
    gsettings set org.cinnamon enabled-applets "$new"

    # Configure panel applications using grouped-window-list
    echo "Configuring panel applications..."

    # Check if jq is available
    if ! command -v jq &> /dev/null; then
        echo "Warning: jq is required for panel configuration but not installed"
        echo "Skipping panel application configuration"
    else
        # Get the grouped-window-list applet ID
        id=$(dconf read /org/cinnamon/enabled-applets 2>/dev/null | grep -oP 'grouped-window-list@cinnamon\.org:\K[0-9]+' | head -n1)

        if [[ -n "$id" ]]; then
            conf="$HOME/.config/cinnamon/spices/grouped-window-list@cinnamon.org/${id}.json"

            # Create directory if it doesn't exist
            mkdir -p "$(dirname "$conf")"

            # Create the proper JSON structure for pinned apps
            desired_config='{
    "pinned-apps": {
        "type": "generic",
        "default": [
            "nemo.desktop",
            "firefox.desktop",
            "org.gnome.Terminal.desktop"
        ],
        "value": [
            "nemo.desktop",
            "google-chrome.desktop",
            "org.wezfurlong.wezterm.desktop"
        ]
    }
}'

            # Check if config already has the correct structure and values
            if [[ -f "$conf" ]] && jq -e '.["pinned-apps"].value' "$conf" >/dev/null 2>&1; then
                current_value=$(jq -c '.["pinned-apps"].value' "$conf" 2>/dev/null)
                expected_value='["nemo.desktop","google-chrome.desktop","org.wezfurlong.wezterm.desktop"]'

                if [[ "$current_value" == "$expected_value" ]]; then
                    echo "✓ Panel applications already configured correctly"
                else
                    echo "Updating panel applications configuration..."
                    echo "$desired_config" | jq '.' > "$conf"
                    echo "✓ Panel applications configured successfully"
                fi
            else
                echo "Creating panel applications configuration..."
                echo "$desired_config" | jq '.' > "$conf"
                echo "✓ Panel applications configured successfully"
            fi
        else
            echo "Warning: Could not find grouped-window-list applet ID"
            echo "Skipping panel application configuration"
        fi
    fi

    # Disable all workspace keyboard shortcuts
    echo "Disabling workspace keyboard shortcuts..."
    keys=(
        switch-to-workspace-up switch-to-workspace-down
        switch-to-workspace-left switch-to-workspace-right
        move-to-workspace-up move-to-workspace-down
        move-to-workspace-left move-to-workspace-right
    )
    for key in "${keys[@]}"; do
        gsettings set org.cinnamon.desktop.keybindings.wm "$key" "[]"
    done

    # Restore keyboard shortcuts
    echo "Restoring keyboard shortcuts..."

    # Custom keybindings
    gsettings set org.cinnamon.desktop.keybindings custom-list "['custom0', '__dummy__']"
    gsettings set org.cinnamon.desktop.keybindings looking-glass-keybinding "['<Super>p']"
    gsettings set org.cinnamon.desktop.keybindings magnifier-zoom-in "[]"
    gsettings set org.cinnamon.desktop.keybindings magnifier-zoom-out "[]"

    # Custom keybinding for CopyQ
    gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom0/ binding "['<Primary><Alt>h']"
    gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom0/ command 'copyq toggle'
    gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom0/ name 'CopyQ shortcutkey'

    # Media keys
    gsettings set org.cinnamon.desktop.keybindings.media-keys calculator "['XF86Calculator', '<Super>k']"
    gsettings set org.cinnamon.desktop.keybindings.media-keys home "['<Super>e', 'XF86Explorer']"
    gsettings set org.cinnamon.desktop.keybindings.media-keys logout "[]"
    gsettings set org.cinnamon.desktop.keybindings.media-keys mute-quiet "['XF86AudioMute', '<Alt><Super>F10']"
    gsettings set org.cinnamon.desktop.keybindings.media-keys screensaver "['<Super>l']"
    gsettings set org.cinnamon.desktop.keybindings.media-keys search "['XF86Search']"
    gsettings set org.cinnamon.desktop.keybindings.media-keys shutdown "['XF86PowerOff']"
    gsettings set org.cinnamon.desktop.keybindings.media-keys terminal "['<Super>t']"
    gsettings set org.cinnamon.desktop.keybindings.media-keys video-outputs "['XF86Display']"
    gsettings set org.cinnamon.desktop.keybindings.media-keys video-rotation-lock "[]"
    gsettings set org.cinnamon.desktop.keybindings.media-keys volume-down-quiet "['<Alt>XF86AudioLowerVolume', '<Alt><Super>F11']"
    gsettings set org.cinnamon.desktop.keybindings.media-keys volume-up-quiet "['<Alt>XF86AudioRaiseVolume', '<Alt><Super>F12']"
    gsettings set org.cinnamon.desktop.keybindings.media-keys www "['XF86WWW']"

    # Window management keys
    gsettings set org.cinnamon.desktop.keybindings.wm begin-move "[]"
    gsettings set org.cinnamon.desktop.keybindings.wm begin-resize "[]"
    gsettings set org.cinnamon.desktop.keybindings.wm move-to-monitor-down "[]"
    gsettings set org.cinnamon.desktop.keybindings.wm move-to-monitor-up "[]"
    gsettings set org.cinnamon.desktop.keybindings.wm panel-run-dialog "['<Super>F2']"
    gsettings set org.cinnamon.desktop.keybindings.wm push-snap-down "['<Alt><Super>Down']"
    gsettings set org.cinnamon.desktop.keybindings.wm push-snap-left "['<Alt><Super>Left']"
    gsettings set org.cinnamon.desktop.keybindings.wm push-snap-right "['<Alt><Super>Right']"
    gsettings set org.cinnamon.desktop.keybindings.wm push-snap-up "['<Alt><Super>Up']"
    gsettings set org.cinnamon.desktop.keybindings.wm switch-to-workspace-down "['<Primary><Super>Down']"
    gsettings set org.cinnamon.desktop.keybindings.wm toggle-maximized "[]"
    gsettings set org.cinnamon.desktop.keybindings.wm unmaximize "[]"

    echo "✓ Keyboard shortcuts restored"
    echo "✓ Cinnamon workspace functionality properly disabled"
else
    echo "⚠ gsettings not available, skipping Cinnamon workspace configuration"
fi

echo ""
echo "System configuration completed successfully!"
echo ""
echo "Applied configurations:"
echo "✓ Manjaro Hello disabled"
echo "✓ Lid switch set to lock"
echo "✓ Systemd timeout set to 10s"
echo "✓ Keyboard repeat settings configured"
echo "✓ Japanese directories renamed to English"
echo "✓ XDG user directories updated"
echo "✓ Nemo bookmarks updated to English directories"
echo "✓ Autologin configured for tty1-3"
echo "✓ Cinnamon workspace functionality disabled"
echo "✓ Panel applications configured (Chrome, Wezterm added)"
echo "✓ Keyboard shortcuts restored"
echo ""
echo "Some changes require a reboot to take effect."
echo "================================"
