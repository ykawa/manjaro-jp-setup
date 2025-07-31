#!/bin/bash

# Main Setup Script for Manjaro Linux Development Environment
# This script orchestrates the entire setup process

set -e

# Check if running non-interactively (piped from curl)
NON_INTERACTIVE=false
if [ ! -t 0 ] || [ "$1" = "--non-interactive" ] || [ "$1" = "--auto" ]; then
    NON_INTERACTIVE=true
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$HOME/setup.log"

echo "================================"
echo "  Manjaro Linux Setup Script"
echo "  Development Environment Setup"
echo "================================"
echo ""

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to run script with error handling
run_script() {
    local script_name="$1"
    local script_path="$SCRIPT_DIR/scripts/$script_name"

    if [ ! -f "$script_path" ]; then
        log_message "ERROR: Script $script_name not found!"
        return 1
    fi

    log_message "Running $script_name..."

    # Make script executable
    chmod +x "$script_path"

    # Run the script
    if "$script_path" 2>&1 | tee -a "$LOG_FILE"; then
        log_message "SUCCESS: $script_name completed successfully"
        return 0
    else
        log_message "ERROR: $script_name failed"
        return 1
    fi
}

# Function to get available scripts dynamically
get_available_scripts() {
    local scripts=()
    for script in "$SCRIPT_DIR"/scripts/[0-9]*-*.sh; do
        if [ -f "$script" ]; then
            scripts+=("$(basename "$script")")
        fi
    done
    printf '%s\n' "${scripts[@]}" | sort -V
}

# Function to display menu
show_menu() {
    echo ""
    echo "Available setup scripts:"

    local counter=1
    while IFS= read -r script; do
        # Extract description from script name
        local desc=$(echo "$script" | sed 's/^[0-9]*-//' | sed 's/-/ /g' | sed 's/\.sh$//' | sed 's/\b\w/\u&/g')
        printf "%2d. %s (%s)\n" "$counter" "$desc" "$script"
        ((counter++))
    done < <(get_available_scripts)

    echo "$counter. Run All Scripts"
    echo "$((counter + 1)). Exit"
    echo ""
}

# Function to prompt for confirmation
confirm_action() {
    local action="$1"

    # Skip confirmation in non-interactive mode
    if [ "$NON_INTERACTIVE" = true ]; then
        log_message "Auto-confirming: $action"
        return 0
    fi

    read -p "Are you sure you want to $action? (y/N): " confirm
    [[ "$confirm" =~ ^[Yy]$ ]]
}

# Initialize log file
log_message "Starting Manjaro Linux setup process"
log_message "Current user: $(whoami)"
log_message "Current directory: $(pwd)"
log_message "Script directory: $SCRIPT_DIR"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    log_message "WARNING: Running as root. This may cause permission issues."
    if ! confirm_action "continue as root"; then
        log_message "Setup cancelled by user"
        exit 1
    fi
fi

# Check if sudo is available
if ! command -v sudo &> /dev/null; then
    log_message "ERROR: sudo is not installed or not available"
    exit 1
fi

# Get available scripts
mapfile -t available_scripts < <(get_available_scripts)

# Run in non-interactive mode
if [ "$NON_INTERACTIVE" = true ]; then
    log_message "Running in non-interactive mode - executing all scripts automatically"

    if confirm_action "run all setup scripts"; then
        log_message "Running all setup scripts..."

        failed_scripts=()

        for script in "${available_scripts[@]}"; do
            if ! run_script "$script"; then
                failed_scripts+=("$script")
            fi
        done

        echo ""
        if [ ${#failed_scripts[@]} -eq 0 ]; then
            log_message "All setup scripts completed successfully!"

            # Restore screen saver settings
            echo ""
            log_message "Restoring original screen saver and power management settings..."
            if [ -f "$SCRIPT_DIR/scripts/9999-restore-screensaver.sh" ]; then
                "$SCRIPT_DIR/scripts/9999-restore-screensaver.sh" 2>&1 | tee -a "$LOG_FILE"
            else
                echo "Note: Screen saver restore script not found. Settings may remain disabled."
            fi

            echo ""
            echo "======================================"
            echo "  Setup Completed Successfully!"
            echo "======================================"
            echo ""
            echo "🔄 RECOMMENDED: Reboot your system to apply all changes"
            echo "   sudo reboot"
            echo ""
            echo "📝 OPTIONAL: Install Japanese Windows 11 fonts for better compatibility"
            echo "   yay -S --needed --noconfirm ttf-ms-win11-auto-japanese"
            echo ""
            echo "======================================"
        else
            log_message "Some scripts failed: ${failed_scripts[*]}"
            exit 1
        fi
    fi
else
    # Interactive mode - main menu loop
    while true; do
        show_menu

        script_count=${#available_scripts[@]}
        run_all_option=$((script_count + 1))
        exit_option=$((script_count + 2))

        read -p "Please select an option (1-$exit_option): " choice

        # Validate input
        if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "$exit_option" ]; then
            echo "Invalid option. Please select 1-$exit_option."
            continue
        fi

        if [ "$choice" -eq "$exit_option" ]; then
            log_message "Setup process ended by user"
            echo "Setup process ended. Check $LOG_FILE for details."
            break
        elif [ "$choice" -eq "$run_all_option" ]; then
            if confirm_action "run all setup scripts"; then
                log_message "Running all setup scripts..."

                failed_scripts=()

                for script in "${available_scripts[@]}"; do
                    if ! run_script "$script"; then
                        failed_scripts+=("$script")
                    fi
                done

                echo ""
                if [ ${#failed_scripts[@]} -eq 0 ]; then
                    log_message "All setup scripts completed successfully!"

                    # Restore screen saver settings
                    echo ""
                    log_message "Restoring original screen saver and power management settings..."
                    if [ -f "$SCRIPT_DIR/scripts/9999-restore-screensaver.sh" ]; then
                        "$SCRIPT_DIR/scripts/9999-restore-screensaver.sh" 2>&1 | tee -a "$LOG_FILE"
                    else
                        echo "Note: Screen saver restore script not found. Settings may remain disabled."
                    fi

                    echo ""
                    echo "======================================"
                    echo "  Setup Completed Successfully!"
                    echo "======================================"
                    echo ""
                    echo "🔄 RECOMMENDED: Reboot your system to apply all changes"
                    echo "   sudo reboot"
                    echo ""
                    echo "📝 OPTIONAL: Install Japanese Windows 11 fonts for better compatibility"
                    echo "   yay -S --needed --noconfirm ttf-ms-win11-auto-japanese"
                    echo ""
                    echo "======================================"
                else
                    log_message "Some scripts failed: ${failed_scripts[*]}"
                fi
            fi
        else
            # Run individual script
            selected_script="${available_scripts[$((choice - 1))]}"
            script_desc=$(echo "$selected_script" | sed 's/^[0-9]*-//' | sed 's/-/ /g' | sed 's/\.sh$//')

            if confirm_action "run $script_desc"; then
                run_script "$selected_script"
            fi
        fi
    done
fi

log_message "Setup script finished"
echo ""
echo "Setup process completed!"
echo "Log file: $LOG_FILE"
echo "================================"
