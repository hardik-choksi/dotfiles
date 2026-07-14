# NixOS Configuration

This directory is the source of truth. (It began as a copy of a `nixos-config`
repo that turned out not to be ours; that remote has been severed.)

Verified: the whole config evaluates cleanly — `nix build
.#nixosConfigurations.nixos.config.system.build.toplevel --dry-run` exits 0, so
every module option and package attribute resolves. It has not been *booted*,
only evaluated.

## Files

| File | Contents |
|------|----------|
| `flake.nix` | Inputs: nixpkgs, home-manager, plasma-manager |
| `configuration.nix` | System: KDE Plasma 6, SDDM, pipewire, packages, user |
| `home.nix` | home-manager: zsh + p10k, shell aliases, dev packages |
| `plasma.nix` | KDE config via plasma-manager (see below) |
| `hardware-configuration.nix` | **Machine-generated — do not reuse.** See below. |

## ⚠️ Regenerate `hardware-configuration.nix` first

The `hardware-configuration.nix` committed here describes **a different
machine** — it carries that box's disk UUIDs and kernel modules. Using it as-is
on a new install will not boot.

Before the first rebuild on any new machine:

```bash
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

Nothing else in the config is machine-specific, so this is the only file you
need to touch. (The evaluation above was done against a stub hardware config,
which is why regenerating it doesn't invalidate that result.)

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

## Usage — installing on a new machine

```bash
git clone git@github.com:hardik-choksi/dotfiles.git ~/dotfiles
cp -r ~/dotfiles/nixos ~/nixos-config && cd ~/nixos-config

# 1. REQUIRED. The committed hardware-configuration.nix is for another
#    machine; without this the system will not boot.
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix

# 2. Build.
sudo nixos-rebuild switch --flake .#nixos
```

Then:

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
