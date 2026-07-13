#!/bin/bash
# KDE Plasma Configuration Installer
# Usage: ./install.sh [--symlink]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"
TARGET_DIR="$HOME/.config"
KONSOLE_DIR="$HOME/.local/share/konsole"

FILES=(
    kglobalshortcutsrc
    kwinrc
    kdeglobals
    konsolerc
    spectaclerc
    dolphinrc
    kscreenlockerrc
)

echo "KDE Plasma Configuration Installer"
echo "===================================="
echo ""

if [ -z "$KDE_SESSION_VERSION" ] && [ -z "$DESKTOP_SESSION" ]; then
    echo "Warning: KDE Plasma session not detected. Continue anyway? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
fi

# Backup existing configs
echo "Creating backups of existing configurations..."
STAMP="$(date +%Y%m%d_%H%M%S)"
for file in "${FILES[@]}"; do
    if [ -f "$TARGET_DIR/$file" ] && [ ! -L "$TARGET_DIR/$file" ]; then
        cp "$TARGET_DIR/$file" "$TARGET_DIR/$file.backup.$STAMP"
        echo "  Backed up: $file"
    fi
done
echo ""

if [ "$1" = "--symlink" ]; then
    echo "Installing using symbolic links..."
    for file in "${FILES[@]}"; do
        rm -f "$TARGET_DIR/$file"
        ln -sf "$CONFIG_DIR/$file" "$TARGET_DIR/$file"
        echo "  Linked: $file"
    done
    echo ""
    echo "Note: With symlinks, changes in System Settings will auto-update your dotfiles!"
else
    echo "Installing using direct copy..."
    for file in "${FILES[@]}"; do
        cp "$CONFIG_DIR/$file" "$TARGET_DIR/$file"
        chmod 600 "$TARGET_DIR/$file"
        echo "  Copied: $file"
    done
fi

# Konsole profile + colorscheme live under ~/.local/share, always copied
echo ""
echo "Installing Konsole profile..."
mkdir -p "$KONSOLE_DIR"
cp "$CONFIG_DIR"/konsole/* "$KONSOLE_DIR/"
echo "  Installed: $(ls "$CONFIG_DIR/konsole" | tr '\n' ' ')"

echo ""
echo "Installation complete!"
echo ""
echo "To apply changes, choose one:"
echo "  1. Log out and log back in (recommended)"
echo "  2. Restart KWin:"
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    echo "     kwin_wayland --replace &"
else
    echo "     kwin_x11 --replace &"
fi
echo ""
echo "Note: appearance (Andromeda look-and-feel, YAMIS icons) is NOT tracked here."
echo "Those are third-party themes installed by hand into ~/.local/share."
