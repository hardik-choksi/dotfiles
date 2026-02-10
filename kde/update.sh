#!/bin/bash
# Update KDE configurations in dotfiles from current system
# Usage: ./update.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"
SOURCE_DIR="$HOME/.config"

echo "KDE Plasma Configuration Updater"
echo "================================="
echo ""

# Check if configs are symlinks
is_symlinked=true
for file in kglobalshortcutsrc khotkeysrc kwinrc; do
    if [ ! -L "$SOURCE_DIR/$file" ]; then
        is_symlinked=false
        break
    fi
done

if [ "$is_symlinked" = true ]; then
    echo "Your configs are symlinked to dotfiles - already up to date!"
    echo "Just commit the changes:"
    echo ""
    echo "  cd ~/dotfiles"
    echo "  git add kde/config/"
    echo "  git commit -m 'Update KDE keyboard shortcuts'"
    echo "  git push"
    exit 0
fi

# Copy current configs to dotfiles
echo "Copying current KDE configurations to dotfiles..."
for file in kglobalshortcutsrc khotkeysrc kwinrc; do
    if [ -f "$SOURCE_DIR/$file" ]; then
        cp "$SOURCE_DIR/$file" "$CONFIG_DIR/$file"
        echo "  Updated: $file"
    else
        echo "  Warning: $file not found in $SOURCE_DIR"
    fi
done

echo ""
echo "Update complete!"
echo ""
echo "Next steps:"
echo "  cd ~/dotfiles"
echo "  git status  # Review changes"
echo "  git add kde/config/"
echo "  git commit -m 'Update KDE keyboard shortcuts'"
echo "  git push"
