#!/bin/bash

# SSH Configuration Script
# This script sets up SSH keys and basic SSH configuration

set -e

echo "================================"
echo "  SSH Configuration Setup"
echo "================================"
echo ""

SSH_DIR="$HOME/.ssh"

echo "Creating SSH directory..."
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

echo ""
echo "Checking for existing SSH keys..."
if [ -f "$SSH_DIR/id_rsa" ] || [ -f "$SSH_DIR/id_ed25519" ]; then
    echo "✓ SSH keys already exist:"
    ls -la "$SSH_DIR"/*.pub 2>/dev/null || echo "No public keys found"
    SKIP_KEY_GENERATION=true
else
    echo "No SSH keys found, will generate new ones."
    SKIP_KEY_GENERATION=false
fi

if [ "$SKIP_KEY_GENERATION" = false ]; then
    echo ""
    echo "Generating new SSH key pair..."

    # 現在のユーザー名、ホスト名でemailを生成
    EMAIL="$USER@$(hostname)"
    ssh-keygen -t ed25519 -f "$SSH_DIR/id_ed25519" -q -N "" -C "$EMAIL"

    echo ""
    echo "Setting correct permissions..."
    chmod 600 "$KEY_FILE"
    chmod 644 "$KEY_FILE.pub"

    echo ""
    echo "Starting SSH agent and adding key..."
    eval "$(ssh-agent -s)"
    ssh-add "$KEY_FILE"
else
    echo "✓ Using existing SSH keys"
    # Determine which key file exists
    if [ -f "$SSH_DIR/id_ed25519" ]; then
        KEY_FILE="$SSH_DIR/id_ed25519"
    elif [ -f "$SSH_DIR/id_rsa" ]; then
        KEY_FILE="$SSH_DIR/id_rsa"
    fi
fi

echo ""
echo "Configuring SSH config file..."

# Check if SSH config already has our configuration
if [ -f "$SSH_DIR/config" ] && grep -q "# SSH Configuration" "$SSH_DIR/config"; then
    echo "✓ SSH config already configured"
else
    # Backup existing SSH config if it exists and no backup exists yet
    if [ -f "$SSH_DIR/config" ] && [ ! -f "$SSH_DIR/config.backup" ]; then
        echo "Backing up existing SSH config..."
        cp "$SSH_DIR/config" "$SSH_DIR/config.backup"
    fi

    echo "Creating SSH config file..."
    cat > "$SSH_DIR/config" << 'EOF'
# SSH Configuration
Host *
    AddKeysToAgent yes
    UseKeychain yes
    IdentitiesOnly yes
    ServerAliveInterval 60
    ServerAliveCountMax 3

# GitHub
Host github.com
    HostName github.com
    User git
    PreferredAuthentications publickey

# GitLab
Host gitlab.com
    HostName gitlab.com
    User git
    PreferredAuthentications publickey
EOF
    chmod 600 "$SSH_DIR/config"
    echo "✓ SSH config file created"
fi

echo ""
echo "SSH setup completed successfully!"
echo "Your public key:"
cat "$KEY_FILE.pub"
echo ""
echo "Please add this public key to your Git hosting service (GitHub, GitLab, etc.)"
echo "================================"
