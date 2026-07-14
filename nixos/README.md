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
*prebuilt* binary, which would fail on the missing `/lib64/ld-linux` (the same
reason `nvm` can't work here). If you ever want it declared, it's on crates.io
and `rustPlatform.buildRustPackage` + `fetchCrate` would do it.

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

```bash
sudo nixos-rebuild switch --flake .#nixos
```

Docker group membership needs a logout/login (or reboot) to take effect.
