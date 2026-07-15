# NixOS Configuration

This directory is the source of truth. (It began as a copy of a `nixos-config`
repo that turned out not to be ours; that remote has been severed.)

This config is **live** — it is booted and running on an Acer Swift Go 14
(Intel i5). The committed `hardware-configuration.nix` is that machine's real
hardware scan. The package/option set is also verified to evaluate cleanly:
`nix build .#nixosConfigurations.nixos.config.system.build.toplevel --dry-run`
exits 0, so every module option and package attribute resolves.

## Files

| File | Contents |
|------|----------|
| `flake.nix` | Inputs: nixpkgs, home-manager, plasma-manager, antigravity-nix |
| `configuration.nix` | System: KDE Plasma 6, SDDM, pipewire, packages, user |
| `home.nix` | home-manager: zsh + p10k, shell aliases, dev packages |
| `plasma.nix` | KDE config via plasma-manager (see below) |
| `hardware-configuration.nix` | **The Acer's scan. Regenerate on any other machine.** See below. |

## ⚠️ Regenerate `hardware-configuration.nix` on a different machine

The committed `hardware-configuration.nix` is the Acer Swift Go 14's real scan —
its disk UUIDs, swap device and kernel modules. It is correct for *that* box and
wrong for any other. To reuse this config on a **new** machine, regenerate it
first, or the system will not boot:

```bash
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

Nothing else in the config is machine-specific, so this is the only file you
need to touch. (The `--dry-run` evaluation is done against a stub hardware
config, so it stays valid regardless of which machine's scan is committed.)

## KDE

`plasma.nix` reproduces the KDE setup from `../kde` (the Ubuntu box)
declaratively via [plasma-manager](https://github.com/nix-community/plasma-manager):
shortcuts, 5 virtual desktops, KWin effects, night light, fonts, Konsole
profile, **appearance (theme + icons)** and the **bottom panel/taskbar**.

### Appearance — now declarative

The Ubuntu look IS reproduced (it used to be "theme it by hand"; that's no
longer true). None of these themes are in nixpkgs, so `plasma.nix` packages the
two that aren't with small inline `stdenvNoCC.mkDerivation`s (in its `let`
block) and then *selects* them via `programs.plasma.workspace`:

- **Andromeda** global look-and-feel — a pure QML/SVG/ini data package
  ([EliverLara/Andromeda-kde](https://github.com/EliverLara/Andromeda-kde),
  pinned to a commit). It also ships **its own colour scheme** (`Andromeda`) and
  its **Plasma desktop style** (the panel/tray/widget styling), so no separate
  colours or plasma-style package is needed. Selected with
  `workspace.lookAndFeel` + `workspace.colorScheme`.
- **YAMIS** monochrome icons ([googIyEYES/YAMIS](https://github.com/googIyEYES/YAMIS)).
  It's a *monochrome* set that only defines some icons and
  `Inherits=Papirus-Dark` for the rest, so **`papirus-icon-theme` is installed
  as its base** — without it the set has gaps. Selected with
  `workspace.iconTheme = "YAMIS"`.
- **Window decoration** is left to Andromeda (its look-and-feel carries its own
  deco; plasma-manager warns against setting both, so we don't).
- **Aura Glow** (the Burn-My-Windows KWin effect) is the one piece NOT carried
  over: it's a KWin scripted effect and plasma-manager has no option to enable
  third-party KWin effects. Install it by hand if you want it.

home-manager puts the profile's `share/` on `XDG_DATA_DIRS`, which is how Plasma
finds the packaged look-and-feel / icons / colour scheme.

### Panel / taskbar

The bottom panel is declared in `programs.plasma.panels` — kickoff, icon-tasks,
four system-monitor widgets (net/memory/swap/cpu), a separator, system tray, a
24-hour clock, notes and a show-desktop button, in the same order as the Ubuntu
box. It was **hand-transcribed** from `plasma-org.kde.plasma.desktop-appletsrc`:
`rc2nix` cannot capture panels, so there is no automated path. Two caveats:
plasma-manager applies panels by running a plasmashell script (delete-all +
recreate) on activation, so the first apply may flash a harmless KDE
crash-handler popup; and the system-monitor widgets' fine sensor/colour config
is best-effort — titles and chart types are set, but you may need a one-time
tweak in a widget's settings after the first rebuild.

### Not carried over

- **Tiling layouts.** Keyed by per-machine desktop/screen UUIDs. Re-draw with
  `Meta+T`.

The launcher shortcuts resolve by `.desktop` file name, so the target apps must
exist. `Meta+T` Konsole and `Meta+Shift+R` Spectacle come **for free with the
Plasma 6 module** — `services.desktopManager.plasma6.enable = true` installs
konsole, spectacle, kate, okular, dolphin, ark, gwenview and elisa by default,
so they are not listed in `configuration.nix`. Only `Meta+S` Slack is added
explicitly there, because Slack is not a KDE default.

(To *remove* a default KDE app you'd use `environment.plasma6.excludePackages`
— there is no `enableDefaultPackages` toggle for Plasma; that's a GNOME option.
`kcalc` is **not** a default, so add `kdePackages.kcalc` if you want it.)

## Dev tooling

Docker, Kubernetes, Java and DBeaver are configured in `configuration.nix`.
Three of these are not what you'd naively guess:

- **`dbeaver-bin`**, not `dbeaver`. The plain attribute doesn't exist and has
  no alias, so `pkgs.dbeaver` is a hard eval error.
- **`freelens-bin`**, not `openlens`. OpenLens was removed from nixpkgs —
  Mirantis pulled Lens's source in 2023, so it could no longer be rebuilt and
  the project is deprecated. [FreeLens](https://github.com/freelensapp/freelens)
  is the community fork that succeeded it (MIT).
- **`stremio-linux-shell`**, not `stremio`. Plain `stremio` was removed in
  Feb 2026 (it depended on the vulnerable, outdated Qt5 WebEngine) and is now
  a `throw` pointing at this replacement. The binary is still `stremio`, and
  it bundles the streaming server — there's no separate service to enable.
- **No `nvm`.** It cannot work on NixOS: it downloads prebuilt Node binaries
  that expect a dynamic linker at `/lib64/ld-linux-x86-64.so.2`, which NixOS
  does not have. (`fnm` has the same problem — it's also just a downloader of
  upstream binaries.) `home.nix` pins `nodejs_24`, the current Active LTS.
  For per-project versions, use a devshell pinning `nodejs_20`/`nodejs_22`.

### dz6 (hex editor) — installed by hand

`dz6` isn't in nixpkgs, and is installed imperatively rather than declared here:

```bash
cargo install dz6
```

It lands in `~/.cargo/bin`. Note that a cargo-built binary works on NixOS only
because cargo compiles it against the Nix-provided toolchain — unlike a
*prebuilt* binary, which would fail on the missing `/lib64/ld-linux`. If you
ever want it declared, it's on crates.io and `rustPlatform.buildRustPackage` +
`fetchCrate` would do it.

(`programs.nix-ld.enable` is on, which provides a shim `/lib64/ld-linux` so
*some* foreign prebuilt binaries can run after all — but pinning packages from
nixpkgs, or building from source like this, is still the clean path.)

### Disk imaging (balena-etcher is gone)

`configuration.nix` installs **`caligula`** (a Rust TUI imager) and **`popsicle`**
(a GTK GUI imager) for flashing OS images to USB/SD. Balena Etcher is **not**
here on purpose: it was *removed* from nixpkgs entirely (not merely broken), so
`pkgs.balena-etcher` is a missing-attribute error with no `permittedInsecurePackages`
fix. Upstream ships it as an Electron app whose bundled Electron goes EOL every
few months; maintainers stopped chasing it and now point users at popsicle.

### Flatpak

`services.flatpak.enable` is on, as an escape hatch for apps nixpkgs doesn't
carry or has dropped (OpenLens, for one, is still on Flathub). Two caveats:

- **No remote is configured.** The module gives you the `flatpak` command but
  nothing to install from. Add Flathub once, by hand, after the first rebuild:
  ```bash
  flatpak remote-add --if-not-exists flathub \
    https://flathub.org/repo/flathub.flatpakrepo
  ```
- **Anything installed via Flatpak is outside Nix** — not declared by this
  flake, not rolled back by `nixos-rebuild`. Prefer nixpkgs where possible.

### Docker

Docker is **rootful** (`virtualisation.docker.enable`), and `hardik` is in the
`docker` group. Be aware that group membership is **effectively root** — a
member can bind-mount the host filesystem into a privileged container. That's
inherent to the Docker socket on any distro, and it's what `kind` needs;
rootless Docker + kind requires cgroup-delegation work that is known to be
flaky on NixOS.

`programs.java.enable` is used rather than dropping the JDK into
`systemPackages`, because it also sets `JAVA_HOME`.

## Usage

### Rebuilding this machine (the Acer)

The committed `hardware-configuration.nix` is already this box's scan, so just
rebuild from wherever the config lives:

```bash
sudo nixos-rebuild switch --flake .#nixos
```

### Installing on a new machine

```bash
git clone git@github.com:hardik-choksi/dotfiles.git ~/dotfiles
cd ~/dotfiles/nixos

# 1. REQUIRED. The committed hardware-configuration.nix is the Acer's; on any
#    other machine, replace it with that machine's own scan or it won't boot.
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix

# 2. Build.
sudo nixos-rebuild switch --flake .#nixos
```

Then (first install only):

- **Log out and back in.** The `docker` and `pcap` group memberships don't
  apply to an already-running session.
- Optionally add the Flathub remote (see the Flatpak section above).

Expect the first build to pull a lot: VS Code, Cursor, Postman, DBeaver,
FreeLens, Stremio and the full KDE stack are all sizeable.

### Checking changes before you rebuild

```bash
nix build .#nixosConfigurations.nixos.config.system.build.toplevel --dry-run
```

Evaluates every option and package without downloading or compiling anything.
Catches typo'd options and nonexistent attributes in seconds.
