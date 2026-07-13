# NixOS Configuration

Snapshot of `~/nixos-config`, which also lives in its own repo at
`github.com:vyasn30/nixos-config`. **That repo is the source of truth** — this
is a copy for convenience, and the two will drift unless you sync them by hand.

## Files

| File | Contents |
|------|----------|
| `flake.nix` | Inputs: nixpkgs, home-manager, plasma-manager |
| `configuration.nix` | System: KDE Plasma 6, SDDM, pipewire, packages, user |
| `home.nix` | home-manager: zsh + p10k, shell aliases, dev packages |
| `plasma.nix` | KDE config via plasma-manager (see below) |
| `hardware-configuration.nix` | **Machine-generated.** Contains disk UUIDs for one specific machine — regenerate with `nixos-generate-config` on a new box, do not reuse. |

## KDE

`plasma.nix` reproduces the KDE setup from `../kde` (the Ubuntu box)
declaratively via [plasma-manager](https://github.com/nix-community/plasma-manager):
shortcuts, 5 virtual desktops, KWin effects, night light, fonts, Konsole profile.

Two things deliberately do **not** carry over:

- **Appearance.** The Ubuntu look (Andromeda look-and-feel, YAMIS icons,
  MateriaDark colours, Apple-Aurora decorations, Aura Glow effect) is
  hand-installed under `~/.local/share` and is not in nixpkgs. NixOS comes up
  with stock Breeze; theme it by hand if you want the same look.
- **Tiling layouts.** Keyed by per-machine desktop/screen UUIDs. Re-draw with
  `Meta+T`.

The launcher shortcuts (`Meta+T` Konsole, `Meta+S` Slack, `Meta+Shift+R`
Spectacle) resolve by `.desktop` file name, so `configuration.nix` installs
those packages — without them the keys silently do nothing.

## Usage

```bash
sudo nixos-rebuild switch --flake .#nixos
```
