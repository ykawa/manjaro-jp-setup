#!/bin/bash

# Disable Standard Folder Rename Dialog
# This script prevents the "Update standard folder names to current language?" dialog

set -e

echo "================================"
echo "  Disable Folder Rename Dialog"
echo "  For Japanese Locale"
echo "================================"
echo ""

echo "Disabling standard folder rename dialog..."

# Create user config directory if it doesn't exist
mkdir -p "$HOME/.config"

# Disable xdg-user-dirs-gtk-update by creating a config file
echo "Creating xdg-user-dirs configuration..."
cat > "$HOME/.config/user-dirs.conf" << 'EOF'
# Configuration for xdg-user-dirs
# This prevents the dialog asking to update folder names to current language

enabled=False
EOF

echo "✓ xdg-user-dirs-gtk-update disabled"

# Also disable the autostart entry if it exists
AUTOSTART_FILE="$HOME/.config/autostart/user-dirs-update-gtk.desktop"
if [ -f "$AUTOSTART_FILE" ]; then
    echo "Disabling autostart entry..."
    echo "Hidden=true" >> "$AUTOSTART_FILE"
    echo "✓ Autostart entry disabled"
else
    # Create a disabled autostart entry to prevent future enabling
    echo "Creating disabled autostart entry..."
    mkdir -p "$HOME/.config/autostart"
    cat > "$AUTOSTART_FILE" << 'EOF'
[Desktop Entry]
Type=Application
Name=User Directories Update
Comment=Update standard folder names to current language
Exec=/usr/bin/xdg-user-dirs-gtk-update
Icon=folder
StartupNotify=false
NoDisplay=true
Hidden=true
EOF
    echo "✓ Disabled autostart entry created"
fi

# Kill any running xdg-user-dirs-gtk-update processes
if pgrep -f "xdg-user-dirs-gtk-update" > /dev/null; then
    echo "Stopping running xdg-user-dirs-gtk-update processes..."
    pkill -f "xdg-user-dirs-gtk-update" || true
    echo "✓ Running processes stopped"
fi

# Create user-dirs.dirs file to set English folder names permanently
echo "Setting standard folder names to English..."
cat > "$HOME/.config/user-dirs.dirs" << 'EOF'
# This file is written by xdg-user-dirs-update
# If you want to change or add directories, just edit the line you're
# interested in. All local changes will be retained on the next run.
# Format is XDG_xxx_DIR="$HOME/yyy", where yyy is a shell-escaped
# homedir-relative path, or XDG_xxx_DIR="/yyy", where /yyy is an
# absolute path. No other format is supported.
# 
XDG_DESKTOP_DIR="$HOME/Desktop"
XDG_DOWNLOAD_DIR="$HOME/Downloads"
XDG_TEMPLATES_DIR="$HOME/Templates"
XDG_PUBLICSHARE_DIR="$HOME/Public"
XDG_DOCUMENTS_DIR="$HOME/Documents"
XDG_MUSIC_DIR="$HOME/Music"
XDG_PICTURES_DIR="$HOME/Pictures"
XDG_VIDEOS_DIR="$HOME/Videos"
EOF

echo "✓ Standard folder names set to English"

# Set the locale for xdg-user-dirs to prevent future language changes
echo "Configuring xdg-user-dirs locale..."
cat > "$HOME/.config/user-dirs.locale" << 'EOF'
en_US
EOF

echo "✓ xdg-user-dirs locale set to English"

echo ""
echo "================================"
echo "  Folder Rename Dialog Disabled"
echo "================================"
echo ""
echo "✓ Standard folder rename dialog has been disabled"
echo "✓ Folder names will remain in English"
echo "✓ No more language update prompts will appear"
echo ""
