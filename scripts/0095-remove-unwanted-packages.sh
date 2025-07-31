#!/bin/bash

# Remove Unwanted Packages Script for Manjaro Linux
# This script removes unwanted packages and configurations to clean up the system
# Requires yay to be installed first

set -e

echo "========================================"
echo "  Remove Unwanted Packages"
echo "  System Cleanup for Manjaro Linux"
echo "========================================"
echo ""

# Check if yay is available
if ! command -v yay &> /dev/null; then
    echo "Error: yay is not installed. Please run 0090-yay-install.sh first."
    exit 1
fi

echo "Starting cleanup of unwanted packages and configurations..."
echo ""

# Remove unwanted packages first
echo "Removing unwanted packages..."

# Define packages to remove with descriptions
declare -A packages_to_remove=(
    ["clipit"]="Clipboard manager"
    ["pidgin"]="Multi-protocol instant messaging client"
    ["pidgin-libnotify"]="Pidgin notification plugin"
    ["vivaldi"]="Vivaldi web browser"
    ["vivaldi-bin"]="Vivaldi web browser (binary)"
    ["vivaldi-stable"]="Vivaldi web browser (stable)"
    ["nano"]="Simple text editor"
    ["nano-syntax-highlighting"]="Nano syntax highlighting"
    ["micro"]="Modern terminal text editor"
    ["celluloid"]="GTK frontend for mpv"
    ["lollypop"]="GNOME music player"
    ["mpv"]="Media player"
)

# Remove packages one by one to ensure complete removal
for package in "${!packages_to_remove[@]}"; do
    if pacman -Q "$package" >/dev/null 2>&1; then
        echo "Removing $package (${packages_to_remove[$package]})..."
        yay -R --noconfirm "$package" 2>/dev/null || echo "  Warning: Failed to remove $package"
    else
        echo "✓ $package not installed, skipping"
    fi
done

echo ""
echo "Removing application configurations and cache..."

# Remove Vivaldi configuration and cache
echo "Removing Vivaldi configuration and cache..."
if [ -d "$HOME/.config/vivaldi" ] || [ -d "$HOME/.cache/vivaldi" ]; then
    rm -rf "$HOME/.config/vivaldi" "$HOME/.cache/vivaldi" 2>/dev/null || true
    echo "✓ Vivaldi configuration and cache removed"
else
    echo "✓ No Vivaldi configuration found"
fi

# Remove Pidgin configuration if it exists
echo "Removing Pidgin configuration..."
if [ -d "$HOME/.purple" ]; then
    rm -rf "$HOME/.purple" 2>/dev/null || true
    echo "✓ Pidgin configuration removed"
else
    echo "✓ No Pidgin configuration found"
fi

# Remove Lollypop configuration if it exists
echo "Removing Lollypop configuration..."
if [ -d "$HOME/.local/share/lollypop" ]; then
    rm -rf "$HOME/.local/share/lollypop" 2>/dev/null || true
    echo "✓ Lollypop configuration removed"
else
    echo "✓ No Lollypop configuration found"
fi

echo ""
echo "Removing lib32 packages..."

# Get list of lib32 packages
lib32_packages=$(pacman -Q | grep "^lib32-" | cut -d' ' -f1 2>/dev/null || true)

if [ -n "$lib32_packages" ]; then
    echo "Found lib32 packages to remove:"
    echo "$lib32_packages"
    echo ""

    # Convert to array for better handling
    lib32_array=($lib32_packages)

    # Remove packages in batches to handle dependencies better
    echo "Attempting to remove all lib32 packages at once..."
    if yay -R --noconfirm "${lib32_array[@]}" 2>/dev/null; then
        echo "✓ All lib32 packages removed successfully"
    else
        echo "Batch removal failed, trying individual removal..."
        for package in "${lib32_array[@]}"; do
            if pacman -Q "$package" >/dev/null 2>&1; then
                echo "Removing $package..."
                if yay -R --noconfirm "$package" 2>/dev/null; then
                    echo "  ✓ $package removed"
                else
                    echo "  Warning: Failed to remove $package (may have dependencies)"
                    # Try removing with dependencies
                    yay -Rs --noconfirm "$package" 2>/dev/null || echo "  ✗ Could not remove $package even with dependencies"
                fi
            fi
        done
    fi

    # Check remaining lib32 packages
    remaining_lib32=$(pacman -Q | grep "^lib32-" | cut -d' ' -f1 2>/dev/null || true)
    if [ -n "$remaining_lib32" ]; then
        echo "Warning: Some lib32 packages could not be removed:"
        echo "$remaining_lib32"
        echo "These may be required by other packages"
    else
        echo "✓ All lib32 packages successfully removed"
    fi
else
    echo "✓ No lib32 packages found"
fi

# Configure lib32 package prevention
echo ""
echo "Configuring pacman to ignore lib32 packages..."
if ! grep -q "IgnorePkg.*lib32-" /etc/pacman.conf; then
    sudo sed -i '/^#IgnorePkg/a IgnorePkg = lib32-*' /etc/pacman.conf
    echo "✓ pacman configured to ignore lib32 packages"
else
    echo "✓ pacman already configured to ignore lib32 packages"
fi

# Clean package cache
echo ""
echo "Cleaning package cache..."
yay -Sc --noconfirm || echo "Warning: Failed to clean package cache"

# Remove orphaned packages
echo ""
echo "Removing orphaned packages..."
orphaned_packages=$(pacman -Qtdq 2>/dev/null || true)
if [ -n "$orphaned_packages" ]; then
    echo "Found orphaned packages:"
    echo "$orphaned_packages"
    echo ""
    yay -R --noconfirm $orphaned_packages || echo "Warning: Failed to remove some orphaned packages"
    echo "✓ Orphaned packages removed"
else
    echo "✓ No orphaned packages found"
fi

# Additional cleanup for specific configurations
echo ""
echo "Additional cleanup..."

# Remove .desktop files for removed applications
desktop_files_to_remove=(
    "$HOME/.local/share/applications/vivaldi.desktop"
    "$HOME/.local/share/applications/pidgin.desktop"
    "$HOME/.local/share/applications/lollypop.desktop"
    "$HOME/.local/share/applications/mpv.desktop"
    "$HOME/.local/share/applications/celluloid.desktop"
)

for desktop_file in "${desktop_files_to_remove[@]}"; do
    if [ -f "$desktop_file" ]; then
        rm -f "$desktop_file"
        echo "✓ Removed desktop file: $(basename "$desktop_file")"
    fi
done

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
    echo "✓ Desktop database updated"
fi

echo ""
echo "========================================"
echo "  Unwanted Packages Removal Completed"
echo "========================================"
echo ""
echo "Cleanup summary:"
echo "• Unwanted applications removed"
echo "• Application configurations cleaned"
echo "• lib32 packages removed and blocked"
echo "• Package cache cleaned"
echo "• Orphaned packages removed"
echo "• Desktop files updated"
echo ""
echo "System cleanup completed successfully!"
echo ""
