#!/bin/bash

# Cursor Editor Configuration Script for Manjaro Linux
# This script configures Cursor editor with programming fonts matching WezTerm/Hyper

set -e

echo "====================================="
echo "  Cursor Editor Configuration"
echo "  For Manjaro Linux"
echo "====================================="
echo ""

# Check if cursor is installed
if ! command -v cursor &> /dev/null; then
    echo "Warning: Cursor is not installed. This script will create the configuration"
    echo "         for when Cursor is installed via 0140-productivity-apps.sh"
    echo ""
fi

# Create Cursor configuration directory
CURSOR_CONFIG_DIR="$HOME/.config/Cursor/User"
echo "Creating Cursor configuration directory..."
mkdir -p "$CURSOR_CONFIG_DIR"

# Create settings.json with font configuration matching WezTerm
echo "Configuring Cursor with programming fonts..."
cat > "$CURSOR_CONFIG_DIR/settings.json" << 'EOF'
{
  "workbench.colorTheme": "Dracula",
  "editor.fontFamily": "'Source Han Code JP R', 'M+1Code Nerd Font', 'Fira Code', 'Cica', monospace",
  "editor.fontSize": 16,
  "editor.fontLigatures": true,
  "editor.lineHeight": 1.4,
  "terminal.integrated.fontFamily": "'Source Han Code JP R', 'M+1Code Nerd Font', 'Fira Code', 'Cica', monospace",
  "terminal.integrated.fontSize": 14,
  "terminal.integrated.lineHeight": 1.0,
  "editor.renderWhitespace": "boundary",
  "editor.rulers": [
    132,
    256
  ],
  "editor.wordWrap": "off",
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "editor.detectIndentation": true,
  "files.autoSave": "onFocusChange",
  "files.autoSaveDelay": 1000,
  "editor.formatOnSave": true,
  "editor.formatOnPaste": false,
  "editor.bracketPairColorization.enabled": true,
  "editor.guides.bracketPairs": "active",
  "editor.minimap.enabled": true,
  "editor.minimap.side": "right",
  "workbench.iconTheme": "material-icon-theme",
  "workbench.tree.indent": 20,
  "explorer.confirmDelete": false,
  "explorer.confirmDragAndDrop": false,
  "git.enableSmartCommit": true,
  "git.confirmSync": false,
  "extensions.ignoreRecommendations": false,
  "telemetry.telemetryLevel": "off",
  "update.mode": "manual",
  "workbench.welcomePage.walkthroughs.openOnInstall": false,
  "workbench.startupEditor": "none",
  "workbench.tips.enabled": false,
  "extensions.showRecommendationsOnlyOnDemand": true,
  "workbench.settings.enableNaturalLanguageSearch": false
}
EOF

# Create keybindings.json for consistent shortcuts
echo "Configuring Cursor keybindings..."
cat > "$CURSOR_CONFIG_DIR/keybindings.json" << 'EOF'
[
  {
    "key": "ctrl+alt+t",
    "command": "workbench.action.terminal.new"
  },
  {
    "key": "ctrl+shift+t",
    "command": "workbench.action.reopenClosedEditor"
  },
  {
    "key": "alt+1",
    "command": "workbench.action.openEditorAtIndex1"
  },
  {
    "key": "alt+2",
    "command": "workbench.action.openEditorAtIndex2"
  },
  {
    "key": "alt+3",
    "command": "workbench.action.openEditorAtIndex3"
  },
  {
    "key": "alt+4",
    "command": "workbench.action.openEditorAtIndex4"
  },
  {
    "key": "alt+5",
    "command": "workbench.action.openEditorAtIndex5"
  },
  {
    "key": "alt+6",
    "command": "workbench.action.openEditorAtIndex6"
  },
  {
    "key": "alt+7",
    "command": "workbench.action.openEditorAtIndex7"
  },
  {
    "key": "alt+8",
    "command": "workbench.action.openEditorAtIndex8"
  },
  {
    "key": "alt+9",
    "command": "workbench.action.openEditorAtIndex9"
  }
]
EOF

# Create snippets directory for code snippets
echo "Creating snippets directory..."
mkdir -p "$CURSOR_CONFIG_DIR/snippets"

# Create global snippets file
cat > "$CURSOR_CONFIG_DIR/snippets/global.code-snippets" << 'EOF'
{
  "Print to console": {
    "scope": "javascript,typescript,javascriptreact,typescriptreact",
    "prefix": "log",
    "body": [
      "console.log('$1');$0"
    ],
    "description": "Log output to console"
  },
  "Current timestamp": {
    "scope": "",
    "prefix": "now",
    "body": [
      "$CURRENT_YEAR-$CURRENT_MONTH-$CURRENT_DATE $CURRENT_HOUR:$CURRENT_MINUTE:$CURRENT_SECOND"
    ],
    "description": "Insert current timestamp"
  },
  "Shebang bash": {
    "scope": "shellscript",
    "prefix": "shebang",
    "body": [
      "#!/bin/bash",
      "",
      "set -e",
      "",
      "$0"
    ],
    "description": "Bash script header with error handling"
  }
}
EOF

# Create extensions.json to auto-install required extensions
echo "Configuring recommended extensions..."
cat > "$CURSOR_CONFIG_DIR/extensions.json" << 'EOF'
{
  "recommendations": [
    "dracula-theme.theme-dracula",
    "pkief.material-icon-theme",
    "ms-vscode.vscode-json",
    "ms-python.python",
    "ms-vscode.cpptools",
    "rust-lang.rust-analyzer",
    "golang.go",
    "ms-vscode.hexeditor",
    "eamodio.gitlens",
    "esbenp.prettier-vscode",
    "bradlc.vscode-tailwindcss"
  ]
}
EOF

# Set proper permissions
echo "Setting proper permissions..."
chmod -R 755 "$CURSOR_CONFIG_DIR"

echo ""
echo "✓ Cursor configuration completed successfully!"
echo ""
echo "Configuration applied:"
echo "  • Font: Source Han Code JP R, M+1Code Nerd Font, Fira Code (matching WezTerm)"
echo "  • Editor font size: 16px"
echo "  • Terminal font size: 14px"
echo "  • Font ligatures enabled"
echo "  • Dracula color theme"
echo "  • Material icon theme"
echo "  • Rulers at 132 and 256 characters"
echo "  • Auto-save enabled"
echo "  • Format on save enabled"
echo "  • Telemetry disabled"
echo "  • Custom keybindings for tab navigation"
echo "  • Global code snippets"
echo ""
echo "Configuration files created:"
echo "  • $CURSOR_CONFIG_DIR/settings.json"
echo "  • $CURSOR_CONFIG_DIR/keybindings.json"
echo "  • $CURSOR_CONFIG_DIR/snippets/global.code-snippets"
echo "  • $CURSOR_CONFIG_DIR/extensions.json"
echo ""
echo "Note: Recommended extensions (Dracula theme, Material icons) will be"
echo "      automatically suggested when you first open Cursor."
echo ""
echo "====================================="
