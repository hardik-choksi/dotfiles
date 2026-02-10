# KDE Plasma Configuration

This directory contains KDE Plasma desktop environment configurations, primarily focused on custom keyboard shortcuts.

## Custom Keyboard Shortcuts

### Desktop Switching
- `Super + H` - Switch to left desktop
- `Super + L` - Switch to right desktop

### Window Movement Between Desktops
- `Super + Shift + H` - Move current window to left desktop
- `Super + Shift + L` - Move current window to right desktop

### Other Notable Shortcuts
- `Super + E` - Open Dolphin file manager
- `Super + T` - Open Konsole terminal
- `Super + R` / `Alt + Space` - Open KRunner
- `Super + W` - Toggle Overview
- `Super + D` - Peek at Desktop
- `Super + 1-9` - Switch to Desktop 1-9
- `Alt + Q` / `Alt + F4` - Close window
- `Super + PgUp` - Maximize window
- `Super + PgDown` - Minimize window

## Configuration Files

- **kglobalshortcutsrc** - Global keyboard shortcuts
- **khotkeysrc** - Custom hotkeys configuration
- **kwinrc** - KWin window manager settings

## Setup on New KDE Plasma Environment

### Automated Installation (Easiest)

Use the provided installation script:

```bash
cd ~/dotfiles/kde

# Option 1: Direct copy (recommended for most users)
./install.sh

# Option 2: Symbolic links (auto-syncs changes)
./install.sh --symlink
```

The script will:
- Backup existing configurations
- Install your custom shortcuts
- Provide instructions for applying changes

### Quick Restore (Manual)

If you prefer manual installation:

#### Method 1: Direct Copy
```bash
# Backup existing configs (optional)
cp ~/.config/kglobalshortcutsrc ~/.config/kglobalshortcutsrc.bak
cp ~/.config/khotkeysrc ~/.config/khotkeysrc.bak
cp ~/.config/kwinrc ~/.config/kwinrc.bak

# Copy configurations from dotfiles
cp ~/dotfiles/kde/config/kglobalshortcutsrc ~/.config/
cp ~/dotfiles/kde/config/khotkeysrc ~/.config/
cp ~/dotfiles/kde/config/kwinrc ~/.config/

# Restart KWin to apply changes
kwin_x11 --replace &  # For X11
# OR
kwin_wayland --replace &  # For Wayland

# Or simply log out and log back in
```

#### Method 2: Symbolic Links (Auto-sync)
This method keeps your configs in sync with the dotfiles repo:

```bash
# Remove existing configs
rm ~/.config/kglobalshortcutsrc ~/.config/khotkeysrc ~/.config/kwinrc

# Create symlinks
ln -sf ~/dotfiles/kde/config/kglobalshortcutsrc ~/.config/kglobalshortcutsrc
ln -sf ~/dotfiles/kde/config/khotkeysrc ~/.config/khotkeysrc
ln -sf ~/dotfiles/kde/config/kwinrc ~/.config/kwinrc

# Restart KWin
kwin_x11 --replace &  # Or kwin_wayland --replace &
```

**Note:** With symlinks, any changes you make via System Settings will automatically update the dotfiles. Remember to commit changes!

### Manual Configuration via GUI

If you prefer to configure shortcuts manually or only want specific ones:

1. **Open System Settings**
   - Press `Alt + Space` or `Super + R` to open KRunner
   - Type "keyboard" and select "Keyboard"
   - Or: `systemsettings5` → Hardware → Input Devices → Keyboard

2. **Navigate to Shortcuts**
   - Click on the "Shortcuts" tab

3. **Configure Desktop Switching**
   - Search for "KWin" in the search box
   - Find "Switch One Desktop to the Left"
     - Click on the shortcut field
     - Press `Super + H`
   - Find "Switch One Desktop to the Right"
     - Click on the shortcut field
     - Press `Super + L`

4. **Configure Window Movement**
   - Still in KWin section:
   - Find "Window One Desktop to the Left"
     - Set to `Super + Shift + H`
   - Find "Window One Desktop to the Right"
     - Set to `Super + Shift + L`

5. **Apply Changes**
   - Click "Apply" at the bottom
   - Changes take effect immediately

### Prerequisites

Before restoring configs, ensure you have:
- Multiple virtual desktops configured (System Settings → Workspace Behavior → Virtual Desktops)
- At least 2 desktops for left/right switching to work

## Updating Configuration

### Using the Update Script (Easiest)

```bash
cd ~/dotfiles/kde
./update.sh
```

The script will copy your current KDE configs to the dotfiles and show you the next steps.

### Manual Update

When you make changes to your KDE shortcuts and want to save them:

```bash
# Copy updated configs to dotfiles (skip if using symlinks)
cp ~/.config/kglobalshortcutsrc ~/dotfiles/kde/config/
cp ~/.config/khotkeysrc ~/dotfiles/kde/config/
cp ~/.config/kwinrc ~/dotfiles/kde/config/

# Commit changes
cd ~/dotfiles
git add kde/config/
git commit -m "Update KDE keyboard shortcuts"
git push
```

**Note:** If you're using symlinks (Method 2), the files are already updated in your dotfiles repo. Just commit directly!

## Troubleshooting

### Shortcuts Not Working After Restore

1. **Restart KWin:**
   ```bash
   kwin_x11 --replace &  # or kwin_wayland --replace &
   ```

2. **Log out and log back in**
   This ensures all KDE services reload the configurations

3. **Check Desktop Count:**
   - System Settings → Workspace Behavior → Virtual Desktops
   - Ensure you have at least 2 desktops configured
   - Desktop switching shortcuts only work with multiple desktops

4. **Verify Configuration Load:**
   ```bash
   # Check if configs exist and are readable
   ls -lh ~/.config/kglobalshortcutsrc
   ls -lh ~/.config/khotkeysrc
   ls -lh ~/.config/kwinrc
   ```

### Conflicts with Other Shortcuts

If shortcuts don't work, they might conflict with:
- Application-specific shortcuts
- System-wide shortcuts
- Desktop environment defaults

Check System Settings → Shortcuts for conflicts (highlighted in yellow/red).

### Permission Issues

If you get permission errors:
```bash
chmod 600 ~/.config/kglobalshortcutsrc
chmod 600 ~/.config/khotkeysrc
chmod 600 ~/.config/kwinrc
```

## Additional KDE Configurations

Consider adding these to your dotfiles:
- `~/.config/plasma-org.kde.plasma.desktop-appletsrc` - Plasma panel/widget layout
- `~/.config/kdeglobals` - Global KDE theme settings
- `~/.config/konsolerc` - Konsole terminal settings
- `~/.config/dolphinrc` - Dolphin file manager settings
