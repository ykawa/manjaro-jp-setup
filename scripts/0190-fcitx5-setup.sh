#!/bin/bash

# Fcitx5 Configuration Script for Manjaro Linux

echo "================================"
echo "  Fcitx5 Configuration Script"
echo "  Using Working Configuration"
echo "================================"
echo ""

# Install fcitx5 if not already installed
echo "Step 1: Installing fcitx5 and Japanese input method..."

# Check if fcitx5 is already installed
if command -v fcitx5 &> /dev/null && pacman -Qi fcitx5-mozc &>/dev/null; then
    echo "✓ fcitx5 and mozc already installed"
else
    # Check if yay is available
    if command -v yay &> /dev/null; then
        echo "Installing fcitx5 and Japanese input support..."
        yay -S --needed --noconfirm fcitx5-im fcitx5-mozc
        echo "✓ fcitx5 and mozc installed"
    else
        echo "⚠ yay not found, installing with pacman..."
        sudo pacman -S --needed --noconfirm fcitx5-im fcitx5-mozc
        echo "✓ fcitx5 and mozc installed"
    fi
fi

echo ""

echo "This script will apply the proven working fcitx5 configuration."
echo "Current fcitx5 config will be backed up."
echo ""

CONFIG_DIR="$HOME/.config/fcitx5"

echo "Step 2: Backing up current configuration..."
if [ -d "$CONFIG_DIR" ]; then
    BACKUP_DIR="$CONFIG_DIR.backup.$(date +%Y%m%d_%H%M%S)"
    mv "$CONFIG_DIR" "$BACKUP_DIR"
    echo "Backup created: $BACKUP_DIR"
fi

echo "Step 3: Creating configuration directory..."
mkdir -p "$CONFIG_DIR/conf"

echo "Step 4: Copying working profile configuration..."
cat > "$CONFIG_DIR/profile" << 'EOF'
[Groups/0]
# Group Name
Name=デフォルト
# Layout
Default Layout=jp
# Default Input Method
DefaultIM=mozc

[Groups/0/Items/0]
# Name
Name=mozc
# Layout
Layout=

[GroupOrder]
0=デフォルト
EOF

echo "Step 5: Copying working main configuration..."
cat > "$CONFIG_DIR/config" << 'EOF'
[Hotkey]
# 入力メソッドの切り替え
TriggerKeys=
# トリガーキーを押すたびに切り替える
EnumerateWithTriggerKeys=False
# 一時的に第1入力メソッドに切り替える
AltTriggerKeys=
# 次の入力メソッドに切り替える
EnumerateForwardKeys=
# 前の入力メソッドに切り替える
EnumerateBackwardKeys=
# 切り替え時は第1入力メソッドをスキップする
EnumerateSkipFirst=False
# 次の入力メソッドグループに切り替える
EnumerateGroupForwardKeys=
# 前の入力メソッドグループに切り替える
EnumerateGroupBackwardKeys=
# 入力メソッドを有効にする
ActivateKeys=
# 入力メソッドをオフにする
DeactivateKeys=
# デフォルトの前ページ
PrevPage=
# デフォルトの次ページ
NextPage=
# デフォルトの前候補
PrevCandidate=
# デフォルトの次候補
NextCandidate=
# 埋め込みプリエディットの切り替え
TogglePreedit=

[Behavior]
# デフォルトで有効にする
ActiveByDefault=True
# フォーカス時に状態をリセット
resetStateWhenFocusIn=Program
# 入力状態を共有する
ShareInputState=Program
# アプリケーションにプリエディットを表示する
PreeditEnabledByDefault=True
# 入力メソッドを切り替える際に入力メソッドの情報を表示する
ShowInputMethodInformation=True
# フォーカスを変更する際に入力メソッドの情報を表示する
showInputMethodInformationWhenFocusIn=True
# 入力メソッドの情報をコンパクトに表示する
CompactInputMethodInformation=True
# 第1入力メソッドの情報を表示する
ShowFirstInputMethodInformation=True
# デフォルトのページサイズ
DefaultPageSize=10
# XKB オプションより優先する
OverrideXkbOption=False
# カスタム XKB オプション
CustomXkbOption=
# Force Enabled Addons
EnabledAddons=
# Force Disabled Addons
DisabledAddons=
# Preload input method to be used by default
PreloadInputMethod=True
# パスワード欄に入力メソッドを許可する
AllowInputMethodForPassword=False
# パスワード入力時にプリエディットテキストを表示する
ShowPreeditForPassword=False
# ユーザーデータを保存する間隔（分）
AutoSavePeriod=30
EOF

echo "Step 6: Copying working Mozc configuration..."
cat > "$CONFIG_DIR/conf/mozc.conf" << 'EOF'
# 初期モード
InitialMode=Direct
# 入力状態の共有
InputState=All
# 候補を縦に並べる
Vertical=True
# 用例の表示 (候補が縦並びのとき)
ExpandMode="On Focus"
# プリエディットカーソルをプリエディットの先頭に固定する
PreeditCursorPositionAtBeginning=False
# 用例を表示するホットキー
ExpandKey=
EOF

echo "Step 7: Copying working XIM configuration..."
cat > "$CONFIG_DIR/conf/xim.conf" << 'EOF'
# XIM で On The Spot スタイルを使う（再起動が必要）
UseOnTheSpot=True
EOF

echo "Step 8: Setting up environment variables..."
ENV_FILE="$HOME/.xprofile"

# Backup existing .xprofile
if [ -f "$ENV_FILE" ]; then
    cp "$ENV_FILE" "$ENV_FILE.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Check if environment variables are already properly set
if [ -f "$ENV_FILE" ] && \
   grep -q "^export GTK_IM_MODULE=fcitx" "$ENV_FILE" && \
   grep -q "^export QT_IM_MODULE=fcitx" "$ENV_FILE" && \
   grep -q "^export XMODIFIERS=@im=fcitx" "$ENV_FILE" && \
   grep -q "^export INPUT_METHOD=fcitx" "$ENV_FILE"; then
    echo "✓ fcitx5 environment variables already configured"
else
    # Remove any existing fcitx settings
    if [ -f "$ENV_FILE" ]; then
        sed -i '/^GTK_IM_MODULE=/d' "$ENV_FILE"
        sed -i '/^QT_IM_MODULE=/d' "$ENV_FILE"
        sed -i '/^XMODIFIERS=@im=/d' "$ENV_FILE"
        sed -i '/^INPUT_METHOD=/d' "$ENV_FILE"
        sed -i '/^export GTK_IM_MODULE=/d' "$ENV_FILE"
        sed -i '/^export QT_IM_MODULE=/d' "$ENV_FILE"
        sed -i '/^export XMODIFIERS=/d' "$ENV_FILE"
        sed -i '/^export INPUT_METHOD=/d' "$ENV_FILE"
    fi

    # Add fcitx5 environment variables
    echo "" >> "$ENV_FILE"
    echo "# fcitx5 environment variables" >> "$ENV_FILE"
    echo "export GTK_IM_MODULE=fcitx" >> "$ENV_FILE"
    echo "export QT_IM_MODULE=fcitx" >> "$ENV_FILE"
    echo "export XMODIFIERS=@im=fcitx" >> "$ENV_FILE"
    echo "export INPUT_METHOD=fcitx" >> "$ENV_FILE"
    echo "✓ fcitx5 environment variables configured"
fi

echo "Step 9: Copying Mozc configuration database..."
MOZC_CONFIG_DIR="$HOME/.config/mozc"

SOURCE_MOZC_CONFIG="$(dirname "$0")/../dot.config/mozc/config1.db"
mkdir -p "$MOZC_CONFIG_DIR"

if [ -f "$SOURCE_MOZC_CONFIG" ]; then
    echo "Copying Mozc config1.db from working configuration..."
    cp "$SOURCE_MOZC_CONFIG" "$MOZC_CONFIG_DIR/config1.db"
    chmod 644 "$MOZC_CONFIG_DIR/config1.db"
    echo "✓ Mozc configuration database copied"
else
    echo "⚠ Warning: Source Mozc config1.db not found at $SOURCE_MOZC_CONFIG"
fi

echo "Step 10: Configuring pacman to ignore Japanese input packages..."
# Configure pacman to ignore Japanese input packages
PACMAN_CONF="/etc/pacman.conf"

# Backup existing pacman.conf if no backup exists yet
if [ ! -f "$PACMAN_CONF.backup" ]; then
    echo "Backing up existing $PACMAN_CONF..."
    sudo cp "$PACMAN_CONF" "$PACMAN_CONF.backup"
fi

# Check if IgnorePkg already exists and is not commented
if grep -q "^IgnorePkg" "$PACMAN_CONF"; then
    echo "Found existing IgnorePkg configuration"
    # Check if our packages are already in the ignore list
    if grep "^IgnorePkg" "$PACMAN_CONF" | grep -q "mozc-\*\|fcitx5-\*"; then
        echo "✓ mozc-* and fcitx5-* already in IgnorePkg"
    else
        echo "Adding mozc-* and fcitx5-* to existing IgnorePkg..."
        # Add to existing IgnorePkg line
        sudo sed -i '/^IgnorePkg/s/$/ mozc-* fcitx5-*/' "$PACMAN_CONF"
        echo "✓ Added to existing IgnorePkg configuration"
    fi
elif grep -q "^#IgnorePkg" "$PACMAN_CONF"; then
    echo "Found commented IgnorePkg configuration"
    # Check if commented line already contains our packages
    if grep "^#IgnorePkg" "$PACMAN_CONF" | grep -q "mozc-\*\|fcitx5-\*"; then
        # Just uncomment the line
        sudo sed -i 's/^#IgnorePkg/IgnorePkg/' "$PACMAN_CONF"
        echo "✓ Uncommented existing IgnorePkg configuration"
    else
        # Uncomment and add our packages
        sudo sed -i 's/^#IgnorePkg.*/IgnorePkg = mozc-* fcitx5-*/' "$PACMAN_CONF"
        echo "✓ Uncommented and configured IgnorePkg"
    fi
else
    echo "No IgnorePkg configuration found, adding new entry..."
    # Add new IgnorePkg line in [options] section
    sudo sed -i '/^\[options\]/a IgnorePkg = mozc-* fcitx5-*' "$PACMAN_CONF"
    echo "✓ Added new IgnorePkg configuration"
fi

echo "Current IgnorePkg configuration:"
grep "^IgnorePkg" "$PACMAN_CONF" || echo "No IgnorePkg configuration found"

echo ""
echo "Step 11: Setting file permissions..."
chmod 644 "$CONFIG_DIR/profile"
chmod 644 "$CONFIG_DIR/config"
chmod 644 "$CONFIG_DIR/conf/mozc.conf"
chmod 644 "$CONFIG_DIR/conf/xim.conf"

echo ""
echo "Step 12: Setting up autostart for fcitx5..."

# Create autostart directory if it doesn't exist
AUTOSTART_DIR="$HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"

# Create fcitx5 autostart file
FCITX5_AUTOSTART="$AUTOSTART_DIR/fcitx5.desktop"

# Check if autostart file already exists with correct content
if [ -f "$FCITX5_AUTOSTART" ] && grep -q "Exec=fcitx5" "$FCITX5_AUTOSTART"; then
    echo "✓ fcitx5 autostart already configured"
else
    cat > "$FCITX5_AUTOSTART" << 'EOF'
[Desktop Entry]
Name=Fcitx 5
GenericName=Input Method
Comment=Start Input Method
Exec=fcitx5
Icon=fcitx
Terminal=false
Type=Application
Categories=System;Utility;
StartupNotify=false
X-GNOME-Autostart-Phase=Applications
X-GNOME-AutoRestart=false
X-GNOME-Autostart-Notify=false
X-KDE-autostart-after=panel
EOF
    echo "✓ fcitx5 autostart configured"
fi

echo ""
echo "Configuration applied successfully!"
echo ""
echo "Applied settings (copied from working config):"
echo "✓ fcitx5 and mozc installed"
echo "✓ Profile with single group containing only Mozc"
echo "✓ All hotkeys disabled"
echo "✓ Mozc initial mode set to Direct"
echo "✓ XIM On The Spot enabled"
echo "✓ Environment variables set to fcitx5"
echo "✓ Mozc configuration database copied"
echo "✓ Pacman configured to ignore Japanese input packages"
echo "✓ Autostart configured for fcitx5"
echo ""
echo "NEXT STEPS:"
echo "1. Log out completely"
echo "2. Log back in"
echo "3. fcitx5 should work exactly like your current setup"
echo ""
echo "This configuration is copied from your working setup"
echo "and should replicate the exact same behavior."
echo "================================"
