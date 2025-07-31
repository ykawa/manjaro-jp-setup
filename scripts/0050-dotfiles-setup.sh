#!/bin/bash

# Dotfiles Management Script for Manjaro Linux
# This script manages dotfiles using symlinks from a central dotfiles directory

set -e

echo "================================"
echo "  Dotfiles Management Script"
echo "  Symlink-based Configuration"
echo "================================"
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/../dotfiles"

# Function to setup dotfiles
setup_dotfiles() {
    echo "Setting up dotfiles from: $DOTFILES_DIR"

    # Create dotfiles directory if it doesn't exist
    mkdir -p "$DOTFILES_DIR"

    # Process all dot.* files in dotfiles directory
    if ls "$DOTFILES_DIR"/dot.* 1> /dev/null 2>&1; then
        for dotfile in "$DOTFILES_DIR"/dot.*; do
            if [ -f "$dotfile" ]; then
                # Extract filename without dot. prefix
                filename=$(basename "$dotfile" | sed 's/^dot\.//')
                target="$HOME/.$filename"

                echo "Processing: $filename"

                # If target exists and is not a symlink, backup it
                if [ -e "$target" ] && [ ! -L "$target" ]; then
                    backup="$target.backup.$(date +%Y%m%d_%H%M%S)"
                    echo "  Backing up existing file to: $backup"
                    mv "$target" "$backup"
                fi

                # Calculate relative path from target to dotfile
                relative_path=$(realpath --relative-to="$(dirname "$target")" "$dotfile")

                # If target is already a symlink to our dotfile (relative or absolute), skip
                if [ -L "$target" ]; then
                    current_link=$(readlink "$target")
                    if [ "$current_link" = "$dotfile" ] || [ "$current_link" = "$relative_path" ]; then
                        echo "  Already linked correctly, skipping"
                        continue
                    else
                        echo "  Removing existing symlink"
                        rm "$target"
                    fi
                fi

                # Create symlink with relative path
                echo "  Creating symlink: $target -> $relative_path"
                ln -s "$relative_path" "$target"
            fi
        done
    else
        echo "No dotfiles found in $DOTFILES_DIR"
    fi

    # Process directories in dotfiles (like .ssh, .config subdirs)
    if ls -d "$DOTFILES_DIR"/dot.*/ 1> /dev/null 2>&1; then
        for dotdir in "$DOTFILES_DIR"/dot.*/; do
            if [ -d "$dotdir" ]; then
                # Extract dirname without dot. prefix
                dirname=$(basename "$dotdir" | sed 's/^dot\.//')
                target="$HOME/.$dirname"

                echo "Processing directory: $dirname"

                # If target exists and is not a symlink, backup it
                if [ -e "$target" ] && [ ! -L "$target" ]; then
                    backup="$target.backup.$(date +%Y%m%d_%H%M%S)"
                    echo "  Backing up existing directory to: $backup"
                    mv "$target" "$backup"
                fi

                # Calculate relative path from target to dotdir
                relative_path=$(realpath --relative-to="$(dirname "$target")" "$dotdir")

                # If target is already a symlink to our dotdir (relative or absolute), skip
                if [ -L "$target" ]; then
                    current_link=$(readlink "$target")
                    if [ "$current_link" = "$dotdir" ] || [ "$current_link" = "$relative_path" ]; then
                        echo "  Already linked correctly, skipping"
                        continue
                    else
                        echo "  Removing existing symlink"
                        rm "$target"
                    fi
                fi

                # Create symlink with relative path
                echo "  Creating symlink: $target -> $relative_path"
                ln -s "$relative_path" "$target"
            fi
        done
    fi
}

# Function to add a new dotfile
add_dotfile() {
    local source_file="$1"
    local dotfile_name="$2"

    if [ ! -f "$source_file" ]; then
        echo "Error: Source file $source_file does not exist"
        return 1
    fi

    if [ -z "$dotfile_name" ]; then
        # Extract filename from source path
        dotfile_name=$(basename "$source_file")
    fi

    # Remove leading dot if present
    dotfile_name=$(echo "$dotfile_name" | sed 's/^\.//')

    local target_dotfile="$DOTFILES_DIR/dot.$dotfile_name"

    echo "Adding dotfile: $source_file -> $target_dotfile"

    # Copy file to dotfiles directory
    cp "$source_file" "$target_dotfile"
    echo "Dotfile added successfully"
}

# Function to list current dotfiles
list_dotfiles() {
    echo "Current dotfiles in $DOTFILES_DIR:"
    if ls "$DOTFILES_DIR"/dot.* 1> /dev/null 2>&1; then
        for dotfile in "$DOTFILES_DIR"/dot.*; do
            if [ -f "$dotfile" ] || [ -d "$dotfile" ]; then
                filename=$(basename "$dotfile" | sed 's/^dot\.//')
                target="$HOME/.$filename"

                if [ -L "$target" ]; then
                    current_link=$(readlink "$target")
                    relative_path=$(realpath --relative-to="$(dirname "$target")" "$dotfile" 2>/dev/null || echo "$dotfile")
                    if [ "$current_link" = "$dotfile" ] || [ "$current_link" = "$relative_path" ]; then
                        status="✓ linked"
                    else
                        status="✗ linked elsewhere"
                    fi
                elif [ -e "$target" ]; then
                    status="✗ exists (not linked)"
                else
                    status="✗ not linked"
                fi

                echo "  .$filename ($status)"
            fi
        done
    else
        echo "  No dotfiles found"
    fi
}

# Main script logic
case "${1:-setup}" in
    "setup")
        setup_dotfiles
        ;;
    "add")
        if [ -z "$2" ]; then
            echo "Usage: $0 add <source_file> [dotfile_name]"
            exit 1
        fi
        add_dotfile "$2" "$3"
        ;;
    "list")
        list_dotfiles
        ;;
    "help")
        echo "Usage: $0 [setup|add|list|help]"
        echo ""
        echo "Commands:"
        echo "  setup                     - Setup symlinks for all dotfiles (default)"
        echo "  add <file> [name]        - Add a file to dotfiles directory"
        echo "  list                     - List current dotfiles and their status"
        echo "  help                     - Show this help message"
        ;;
    *)
        echo "Unknown command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac

echo ""
echo "Dotfiles management completed!"
echo "================================"
