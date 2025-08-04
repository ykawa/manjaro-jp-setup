#!/bin/bash

# Setup Verification Script
# This script verifies that the development environment is properly set up

set -e

echo "================================"
echo "  Setup Verification Script"
echo "================================"
echo ""

# Function to check if command exists
check_command() {
    local cmd="$1"
    local description="$2"

    if command -v "$cmd" &> /dev/null; then
        echo "✓ $description: $(command -v "$cmd")"
        return 0
    else
        echo "✗ $description: NOT FOUND"
        return 1
    fi
}

# Function to check if file exists
check_file() {
    local file="$1"
    local description="$2"

    if [ -f "$file" ]; then
        echo "✓ $description: $file"
        return 0
    else
        echo "✗ $description: NOT FOUND"
        return 1
    fi
}

# Function to check git configuration
check_git_config() {
    local key="$1"
    local description="$2"

    if git config --global "$key" &> /dev/null; then
        echo "✓ $description: $(git config --global "$key")"
        return 0
    else
        echo "✗ $description: NOT SET"
        return 1
    fi
}

echo "Checking system information..."
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d '"' -f2)"
echo "Kernel: $(uname -r)"
echo "User: $(whoami)"
echo ""

echo "Checking basic tools..."
check_command "git" "Git"
check_command "vim" "Vim"
check_command "zsh" "Zsh"
check_command "python3" "Python 3"
check_command "node" "Node.js"
check_command "npm" "NPM"
check_command "nodebrew" "Nodebrew"
check_command "claude" "Claude Code"
check_command "make" "Make"
check_command "gcc" "GCC"
check_command "g++" "G++"
check_command "cmake" "CMake"
check_command "fc-cache" "Font utilities"
echo ""

echo "Checking Python packages..."
if python -c "import pynvim" 2>/dev/null; then
    echo "✓ python-pynvim: installed"
else
    echo "✗ python-pynvim: NOT FOUND"
fi
echo ""

echo "Checking development utilities..."
check_command "curl" "cURL"
check_command "wget" "wget"
check_command "jq" "jq"
check_command "rg" "ripgrep"
check_command "fd" "fd"
check_command "bat" "bat"
check_command "exa" "exa"
check_command "tree" "tree"
check_command "htop" "htop"
echo ""

echo "Checking zsh plugins..."
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    echo "✓ zsh-syntax-highlighting: installed"
else
    echo "✗ zsh-syntax-highlighting: NOT FOUND"
fi

if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    echo "✓ zsh-autosuggestions: installed"
else
    echo "✗ zsh-autosuggestions: NOT FOUND"
fi

if [[ -f /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]]; then
    echo "✓ zsh-history-substring-search: installed"
else
    echo "✗ zsh-history-substring-search: NOT FOUND"
fi

if [[ -d /usr/share/zsh/site-functions ]] && [[ -n "$(ls -A /usr/share/zsh/site-functions)" ]]; then
    echo "✓ zsh-completions: installed"
else
    echo "✗ zsh-completions: NOT FOUND"
fi

if [[ -f /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme ]]; then
    echo "✓ zsh-theme-powerlevel10k: installed"
else
    echo "✗ zsh-theme-powerlevel10k: NOT FOUND"
fi
echo ""

echo "Checking configuration files..."
check_file "$HOME/.bashrc" "Bash configuration"
check_file "$HOME/.bashrc_additions" "Additional bash config"
check_file "$HOME/.zshrc" "Zsh configuration"
check_file "$HOME/.vimrc" "Vim configuration"
check_file "$HOME/.Xmodmap" "X11 keymap configuration"
check_file "$HOME/.gitconfig" "Git configuration"
check_file "$HOME/.ssh/config" "SSH configuration"
echo ""

echo "Checking system configurations..."
if [ -f "/etc/vconsole.conf" ]; then
    echo "✓ vconsole.conf: exists"
    if grep -q "KEYMAP=" /etc/vconsole.conf; then
        echo "  KEYMAP configured: $(grep "KEYMAP=" /etc/vconsole.conf)"
    fi
else
    echo "✗ vconsole.conf: NOT FOUND"
fi

if [ -f "/usr/local/share/kbd/keymaps/caps-to-ctrl.map" ]; then
    echo "✓ Custom keymap: caps-to-ctrl.map exists"
else
    echo "✗ Custom keymap: NOT FOUND"
fi

if [ -f "/usr/local/share/kbd/keymaps/jp106.map" ]; then
    echo "✓ Japanese keymap: jp106.map exists"
else
    echo "✗ Japanese keymap: NOT FOUND"
fi

if [ -f "/etc/default/keyboard" ]; then
    echo "✓ Keyboard configuration: /etc/default/keyboard exists"
    if grep -q "ctrl:nocaps" /etc/default/keyboard; then
        echo "  ctrl:nocaps option configured"
    fi
else
    echo "✗ Keyboard configuration: NOT FOUND"
fi

if systemctl is-enabled caps-to-ctrl.service >/dev/null 2>&1; then
    echo "✓ caps-to-ctrl service: enabled"
else
    echo "✗ caps-to-ctrl service: NOT ENABLED"
fi

# Check Japanese keyboard configuration
if [ -f "/etc/X11/xorg.conf.d/00-keyboard.conf" ]; then
    echo "✓ X11 keyboard configuration: exists"
    if grep -q "jp" /etc/X11/xorg.conf.d/00-keyboard.conf; then
        echo "  Japanese keyboard configured"
    fi
else
    echo "✗ X11 keyboard configuration: NOT FOUND"
fi

# Check pacman IgnorePkg configuration
if grep -q "^IgnorePkg.*mozc-\*\|^IgnorePkg.*fcitx5-\*" /etc/pacman.conf; then
    echo "✓ Pacman IgnorePkg: Japanese input packages ignored"
    echo "  IgnorePkg: $(grep '^IgnorePkg' /etc/pacman.conf)"
else
    echo "✗ Pacman IgnorePkg: Japanese input packages NOT ignored"
fi

# Check system time synchronization
if timedatectl show --property=NTP --value | grep -q "yes"; then
    echo "✓ NTP synchronization: enabled"
else
    echo "✗ NTP synchronization: NOT enabled"
fi

if systemctl is-enabled systemd-timesyncd.service >/dev/null 2>&1; then
    echo "✓ systemd-timesyncd service: enabled"
else
    echo "✗ systemd-timesyncd service: NOT enabled"
fi

# Check Avahi service
if systemctl is-enabled avahi-daemon.service >/dev/null 2>&1; then
    echo "✓ avahi-daemon service: enabled"
    if systemctl is-active avahi-daemon.service >/dev/null 2>&1; then
        echo "✓ avahi-daemon service: active"
    else
        echo "✗ avahi-daemon service: not active"
    fi
else
    echo "✗ avahi-daemon service: NOT enabled"
fi

# Check NSS mDNS configuration
if grep -q "^hosts:" /etc/nsswitch.conf; then
    HOSTS_CONFIG=$(grep "^hosts:" /etc/nsswitch.conf)
    echo "Current hosts config: $HOSTS_CONFIG"

    # Check for proper ordering: mymachines, mdns4_minimal, [NOTFOUND=return]
    if echo "$HOSTS_CONFIG" | grep -q "mymachines.*mdns4_minimal.*\[NOTFOUND=return\]"; then
        echo "✓ NSS mDNS resolution: properly configured"
    elif echo "$HOSTS_CONFIG" | grep -q "mdns"; then
        echo "⚠ NSS mDNS resolution: configured but ordering may be incorrect"
    else
        echo "✗ NSS mDNS resolution: NOT configured"
    fi
else
    echo "✗ NSS hosts configuration: NOT found"
fi
echo ""

echo "Checking shell configuration..."
echo "Current shell: $SHELL"
if [ "$SHELL" = "/usr/bin/zsh" ] || [ "$SHELL" = "/bin/zsh" ]; then
    echo "✓ Default shell is zsh"
else
    echo "✗ Default shell is not zsh"
fi
echo ""

echo "Checking Git configuration..."
check_git_config "user.name" "Git user name"
check_git_config "user.email" "Git user email"
check_git_config "init.defaultBranch" "Git default branch"
echo ""

echo "Checking SSH keys..."
if [ -f "$HOME/.ssh/id_rsa.pub" ]; then
    echo "✓ RSA SSH key found"
elif [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
    echo "✓ Ed25519 SSH key found"
else
    echo "✗ No SSH keys found"
fi
echo ""

echo "Checking system services..."
if systemctl is-active --quiet sshd; then
    echo "✓ SSH daemon: running"
    echo "  SSH status: $(systemctl is-enabled sshd)"
else
    echo "✗ SSH daemon: not running"
fi

# Check sudo configuration
if sudo -n true 2>/dev/null; then
    echo "✓ Sudo: passwordless configured"
else
    echo "✗ Sudo: requires password"
fi
echo ""

echo "Checking package managers..."
if command -v yay &> /dev/null; then
    echo "✓ yay: $(yay --version | head -1)"
else
    echo "✗ yay: NOT FOUND"
fi

if command -v nodebrew &> /dev/null; then
    echo "✓ nodebrew: $(nodebrew -v)"
    echo "  Current Node.js: $(nodebrew ls | grep current)"
else
    echo "✗ nodebrew: NOT FOUND"
fi

if command -v claude &> /dev/null; then
    echo "✓ Claude Code: $(claude --version | head -1)"
else
    echo "✗ Claude Code: NOT FOUND"
fi

# Check Japanese input method
if command -v fcitx5 &> /dev/null; then
    echo "✓ fcitx5: installed"
else
    echo "✗ fcitx5: NOT FOUND"
fi

if [ -f "$HOME/.config/autostart/fcitx5.desktop" ]; then
    echo "✓ fcitx5 autostart: configured"
else
    echo "✗ fcitx5 autostart: NOT CONFIGURED"
fi

# Check installed fonts
echo ""
echo "Checking fonts..."
FONTS_TO_CHECK=(
    "Adobe Source Code Pro"
    "Source Han Sans JP"
    "Source Han Serif"
    "JetBrains Mono"
    "Font Awesome"
)

for font in "${FONTS_TO_CHECK[@]}"; do
    if fc-list | grep -q "$font"; then
        echo "✓ Font available: $font"
    else
        echo "✗ Font missing: $font"
    fi
done
echo ""

echo "Checking PATH..."
echo "Current PATH:"
echo "$PATH" | tr ':' '\n' | nl
echo ""

echo "Checking mouse and touchpad settings..."
# Check X11 configuration files
if [ -f "/etc/X11/xorg.conf.d/50-mouse.conf" ]; then
    echo "✓ Mouse X11 configuration: exists"
else
    echo "✗ Mouse X11 configuration: NOT FOUND"
fi

if [ -f "/etc/X11/xorg.conf.d/51-touchpad.conf" ]; then
    echo "✓ Touchpad X11 configuration: exists"
else
    echo "✗ Touchpad X11 configuration: NOT FOUND"
fi

# Check autostart script
if [ -f "$HOME/.config/autostart/configure-input-devices.desktop" ]; then
    echo "✓ Input devices autostart: configured"
else
    echo "✗ Input devices autostart: NOT CONFIGURED"
fi

if [ -f "$HOME/.local/bin/configure-input-devices.sh" ]; then
    echo "✓ Input devices startup script: exists"
else
    echo "✗ Input devices startup script: NOT FOUND"
fi
echo ""

echo "Checking WezTerm autostart settings..."
# Check WezTerm autostart files
if [ -f "$HOME/.config/autostart/wezterm.desktop" ]; then
    echo "✓ WezTerm autostart entry: exists"
else
    echo "✗ WezTerm autostart entry: NOT FOUND"
fi

if [ -f "$HOME/.config/autostart/wezterm-startup.desktop" ]; then
    echo "✓ WezTerm startup script autostart: exists"
else
    echo "✗ WezTerm startup script autostart: NOT FOUND"
fi

if [ -f "$HOME/.local/bin/start-wezterm.sh" ]; then
    echo "✓ WezTerm startup script: exists"
else
    echo "✗ WezTerm startup script: NOT FOUND"
fi

# Check if WezTerm autostart is in shell profiles
if grep -q "WezTerm autostart" "$HOME/.bashrc" 2>/dev/null; then
    echo "✓ WezTerm autostart in .bashrc: configured"
else
    echo "✗ WezTerm autostart in .bashrc: NOT CONFIGURED"
fi

if grep -q "WezTerm autostart" "$HOME/.zshrc" 2>/dev/null; then
    echo "✓ WezTerm autostart in .zshrc: configured"
else
    echo "✗ WezTerm autostart in .zshrc: NOT CONFIGURED"
fi
echo ""

echo "Checking screen saver and lock settings..."
# Check if we're in a graphical session
if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
    # Check GNOME settings
    if command -v gsettings &> /dev/null && (pgrep -x "gnome-shell" > /dev/null || [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]); then
        echo "GNOME screen saver settings:"
        if gsettings get org.gnome.desktop.screensaver idle-activation-enabled 2>/dev/null | grep -q "false"; then
            echo "✓ GNOME screen saver: disabled"
        else
            echo "✗ GNOME screen saver: enabled"
        fi

        if gsettings get org.gnome.desktop.screensaver lock-enabled 2>/dev/null | grep -q "false"; then
            echo "✓ GNOME screen lock: disabled"
        else
            echo "✗ GNOME screen lock: enabled"
        fi
    fi

    # Check Cinnamon settings
    if command -v gsettings &> /dev/null && (pgrep -x "cinnamon" > /dev/null || [ "$XDG_CURRENT_DESKTOP" = "X-Cinnamon" ]); then
        echo "Cinnamon screen saver settings:"
        if gsettings get org.cinnamon.desktop.screensaver idle-activation-enabled 2>/dev/null | grep -q "false"; then
            echo "✓ Cinnamon screen saver: disabled"
        else
            echo "✗ Cinnamon screen saver: enabled"
        fi

        if gsettings get org.cinnamon.desktop.screensaver lock-enabled 2>/dev/null | grep -q "false"; then
            echo "✓ Cinnamon screen lock: disabled"
        else
            echo "✗ Cinnamon screen lock: enabled"
        fi
    fi

    # Check system sleep targets
    if systemctl is-masked sleep.target >/dev/null 2>&1; then
        echo "✓ System sleep targets: masked"
    else
        echo "✗ System sleep targets: not masked"
    fi
else
    echo "No graphical session detected - screen saver settings not applicable"
fi
echo ""

echo "Verification completed!"
echo "================================"
