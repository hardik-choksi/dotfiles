#!/bin/bash
# KDE Plasma Configuration Installer
# Usage: ./install.sh [--symlink]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"
TARGET_DIR="$HOME/.config"

echo "KDE Plasma Configuration Installer"
echo "===================================="
echo ""

# Check if running KDE
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
for file in kglobalshortcutsrc khotkeysrc kwinrc; do
    if [ -f "$TARGET_DIR/$file" ] && [ ! -L "$TARGET_DIR/$file" ]; then
        cp "$TARGET_DIR/$file" "$TARGET_DIR/$file.backup.$(date +%Y%m%d_%H%M%S)"
        echo "  Backed up: $file"
    fi
done

echo ""

# Install method
if [ "$1" = "--symlink" ]; then
    echo "Installing using symbolic links..."
    for file in kglobalshortcutsrc khotkeysrc kwinrc; do
        rm -f "$TARGET_DIR/$file"
        ln -sf "$CONFIG_DIR/$file" "$TARGET_DIR/$file"
        echo "  Linked: $file"
    done
    echo ""
    echo "Note: With symlinks, changes in System Settings will auto-update your dotfiles!"
else
    echo "Installing using direct copy..."
    for file in kglobalshortcutsrc khotkeysrc kwinrc; do
        cp "$CONFIG_DIR/$file" "$TARGET_DIR/$file"
        chmod 600 "$TARGET_DIR/$file"
        echo "  Copied: $file"
    done
fi

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
echo "Make sure you have multiple virtual desktops configured:"
echo "  System Settings → Workspace Behavior → Virtual Desktops"
