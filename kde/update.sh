#!/bin/bash
# Sync live KDE config back into the dotfiles repo, stripping machine-specific state.
# Usage: ./update.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"
SOURCE_DIR="$HOME/.config"
KONSOLE_SRC="$HOME/.local/share/konsole"

FILES=(
    kglobalshortcutsrc
    kwinrc
    kdeglobals
    konsolerc
    spectaclerc
    dolphinrc
    kscreenlockerrc
)

echo "KDE Plasma Configuration Updater"
echo "================================="
echo ""

# If the configs are symlinked into this repo, live edits already landed here.
is_symlinked=true
for file in "${FILES[@]}"; do
    if [ ! -L "$SOURCE_DIR/$file" ]; then
        is_symlinked=false
        break
    fi
done

if [ "$is_symlinked" = true ]; then
    echo "Your configs are symlinked to dotfiles - already up to date!"
    echo "Note: symlinked files keep machine-specific state (window geometry,"
    echo "tiling UUIDs) that a plain copy would strip. Review before committing."
    echo ""
    echo "  cd ~/dotfiles && git diff"
    echo "  git add kde/ && git commit -m 'Update KDE config'"
    exit 0
fi

echo "Copying current KDE configurations to dotfiles..."

# Shortcuts are already portable — take verbatim.
cp "$SOURCE_DIR/kglobalshortcutsrc" "$CONFIG_DIR/kglobalshortcutsrc"
echo "  kglobalshortcutsrc"

# kwinrc: drop [Tiling][<uuid>] and [Activities] blocks. They are keyed by
# per-machine desktop/screen UUIDs and mean nothing on another host.
awk '
  /^\[Tiling\]\[/   { skip=1; next }
  /^\[Activities\]/ { skip=1; next }
  /^\[/             { skip=0 }
  !skip
' "$SOURCE_DIR/kwinrc" | cat -s > "$CONFIG_DIR/kwinrc"
echo "  kwinrc            (tiling UUIDs stripped)"

# kdeglobals: keep the fonts, accent colour and colour values, but drop names
# that point at hand-installed themes (Andromeda, YAMIS, the colour-scheme
# hash). Those live only in ~/.local/share, so on any other machine the names
# resolve to nothing and KDE silently falls back to Breeze -- carrying them
# around just implies a look the config can't actually deliver.
grep -vE '^(LookAndFeelPackage|ColorSchemeHash|BrowserApplication)=' \
    "$SOURCE_DIR/kdeglobals" \
  | awk '
      /^\[Icons\]$/ { skip=1; next }   # sole content is Theme=<hand-installed>
      /^\[KDE\]$/    { skip=1; next }   # sole content is LookAndFeelPackage
      /^\[/          { skip=0 }
      !skip
    ' | cat -s > "$CONFIG_DIR/kdeglobals"
echo "  kdeglobals        (theme names stripped)"

# konsolerc: drop window geometry and the serialized State blob.
awk '
  /^State/ { next }
  /screen: (Height|Width|XPosition|YPosition|Window-Maximized)=/ { next }
  /^(HDMI-1|eDP-1)/ { next }
  /^[0-9]+ screens: / { next }
  { print }
' "$SOURCE_DIR/konsolerc" | cat -s > "$CONFIG_DIR/konsolerc"
echo "  konsolerc         (geometry stripped)"

# spectaclerc: drop last-save paths.
grep -vE '^(lastImageSaveAsLocation|lastImageSaveLocation)=' \
    "$SOURCE_DIR/spectaclerc" > "$CONFIG_DIR/spectaclerc"
echo "  spectaclerc       (save paths stripped)"

# dolphinrc: drop geometry and directory history.
awk '
  /screen: (Height|Width|XPosition|YPosition)=/ { next }
  /^DirHistory/ { next }
  { print }
' "$SOURCE_DIR/dolphinrc" | cat -s > "$CONFIG_DIR/dolphinrc"
echo "  dolphinrc         (geometry + history stripped)"

cp "$SOURCE_DIR/kscreenlockerrc" "$CONFIG_DIR/kscreenlockerrc"
echo "  kscreenlockerrc"

# Konsole profile + its colour scheme (these live under ~/.local/share).
mkdir -p "$CONFIG_DIR/konsole"
cp "$KONSOLE_SRC"/*.profile "$CONFIG_DIR/konsole/" 2>/dev/null || true
cp "$KONSOLE_SRC"/*.colorscheme "$CONFIG_DIR/konsole/" 2>/dev/null || true
echo "  konsole/          (profile + colorscheme)"

echo ""
echo "Update complete!"
echo ""
echo "Next steps:"
echo "  cd ~/dotfiles"
echo "  git diff          # Review changes"
echo "  git add kde/"
echo "  git commit -m 'Update KDE config'"
echo "  git push"
