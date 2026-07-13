# KDE Plasma Configuration

KDE Plasma settings: keyboard shortcuts, window manager, fonts, and app config.

## Custom Keyboard Shortcuts

### Desktop Switching
- `Super + H` — Switch to left desktop
- `Super + L` — Switch to right desktop
- `Super + 1-5` — Switch to Desktop 1-5

### Window Movement Between Desktops
- `Super + Shift + H` — Move current window to left desktop
- `Super + Shift + L` — Move current window to right desktop

### Window Management
- `Alt + Q` / `Alt + F4` — Close window
- `Super + PgUp` — Maximize window
- `Super + PgDown` — Minimize window

### Desktop Effects
- `Super + O` — Toggle Overview
- `Super + Tab` — Cycle through Overview and Grid View
- `Super + G` — Toggle Grid View
- `Super + C` — Toggle Cube
- `Super + D` — Peek at Desktop

### Application Launchers
- `Super + T` — Konsole
- `Super + R` / `Alt + Space` — KRunner
- `Super + S` — Slack
- `Super + Shift + R` — Record screen region (Spectacle)

These live in `kglobalshortcutsrc` under `[services][<app>.desktop]`, keyed by
`.desktop` file name. `Super + S` only works if a `slack.desktop` exists.

### KWin Effects (Enabled)
Blur, Contrast, Cube, Mouse Mark, Sheet, Translucency, Wobbly Windows.

### Virtual Desktops
5 desktops (`Web`, `code`, + 3 unnamed), single row.

## Configuration Files

| File | Contents |
|------|----------|
| `kglobalshortcutsrc` | All global shortcuts, incl. app launchers |
| `kwinrc` | KWin: effects, virtual desktops, night colour |
| `kdeglobals` | Fonts, colour scheme, look-and-feel, icon theme |
| `konsolerc` | Konsole settings (default profile, colour scheme) |
| `konsole/` | Konsole profile + its colour scheme |
| `spectaclerc` | Screenshot tool settings |
| `dolphinrc` | File manager settings |
| `kscreenlockerrc` | Screen locker settings |

### What is deliberately not tracked

- **`khotkeysrc`** — was tracked here previously, but contained only KDE's
  stock boilerplate (Konqueror mouse gestures and disabled example actions);
  it held no custom hotkeys. KHotkeys is also removed in Plasma 6.
- **Tiling layouts** (`kwinrc` `[Tiling][<uuid>]`) — keyed by per-machine
  desktop/screen UUIDs, so they don't transfer. Re-draw with `Meta+T`.
- **Window geometry, recent-file history, last-save paths** — machine state,
  stripped by `update.sh`.
- **Themes** — the active look (Andromeda look-and-feel, YAMIS icons,
  MateriaDark colours, Aurorae window decorations) is installed by hand into
  `~/.local/share` and is *not* in this repo. `kdeglobals` only *names* them;
  on a machine without them installed, KDE silently falls back to Breeze.

## Setup on a New KDE Plasma Environment

```bash
cd ~/dotfiles/kde

./install.sh            # direct copy (recommended)
./install.sh --symlink  # symlink, so System Settings edits auto-sync
```

The script backs up existing configs, installs these, and copies the Konsole
profile into `~/.local/share/konsole/`.

Then log out and back in (or `kwin_wayland --replace &` / `kwin_x11 --replace &`).

## Updating

```bash
cd ~/dotfiles/kde
./update.sh     # pulls live config back in, stripping machine-specific state
cd ~/dotfiles && git diff && git add kde/ && git commit -m 'Update KDE config'
```

## NixOS

The NixOS box (`~/nixos-config`) reproduces these shortcuts declaratively via
[plasma-manager](https://github.com/nix-community/plasma-manager) — see
`plasma.nix` there. That is the source of truth for NixOS; this directory is
the source of truth for Ubuntu. Keep them in sync by hand.

## Troubleshooting

**Shortcuts not working after restore:** restart KWin (`kwin_wayland --replace &`)
or log out and back in. Ensure you have 5 virtual desktops
(System Settings → Workspace Behavior → Virtual Desktops).

**Conflicts:** System Settings → Shortcuts highlights conflicting bindings.
