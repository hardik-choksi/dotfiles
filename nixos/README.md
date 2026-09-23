# Reusable NixOS work laptops

This flake builds a reproducible KDE Plasma work laptop for backend,
observability and Kubernetes development. Host hardware and migration state are
isolated from shared workstation modules.

## Layout

```text
flake.nix                         host registry and shared inputs
hosts/<hostname>/default.nix      hostname, boot method and stateVersion
hosts/<hostname>/hardware-configuration.nix
modules/core.nix                  user, locale, Nix policy and admin tools
modules/desktop.nix               Plasma, audio, Bluetooth and printing
modules/development.nix           nix-ld, Java, man pages and IDE limits
modules/containers.nix            explicit rootful Docker/kind profile
modules/home-manager.nix          Home Manager integration
home/hardik/default.nix           user applications and development tools
```

The current host is `acer-swift`:

```bash
sudo nixos-rebuild switch --flake .#acer-swift
```

## Installed work environment

- Editors/apps: VS Code, Cursor, Zed, Kate, Obsidian, DBeaver, Postman, Slack,
  Element, Telegram, KeePassXC, Brave, Codex, Claude Code and Antigravity.
- Runtimes/build: Go, Node 24, Python, Rust/Cargo, GCC, Make, pkg-config and the
  system Java runtime with `JAVA_HOME`.
- Kubernetes: kubectl, Helm, kubectx/kubens, stern, k9s, kind, FreeLens,
  lazydocker and rootful Docker.
- Observability/debugging: `ldd`, binutils, elfutils, patchelf, GDB, ltrace,
  strace, radare2, pahole, valgrind, bpftrace, perf, sysstat, lsof and procps.
- Networking/CLI: tcpdump, mtr, dig, ip/ss, traceroute, socat, nmap, ripgrep,
  jq, bat, btop, fzf, zellij, man pages and the remaining utilities declared in
  `home/hardik/default.nix`.

`LD_PRELOAD` is a glibc dynamic-linker feature rather than a separate package.
The configuration includes glibc tools, `ldd`, `patchelf`, binutils and nix-ld
for inspecting and running dynamically linked software. liburing is installed
with its command-line tools, development headers and io_uring man pages.

Stremio is intentionally not managed here. Zsh, shell aliases, SSH identities,
KWallet automation, KDE shortcuts/themes and mutable prompt configuration are
also intentionally outside this repository.

## Add another laptop

1. Copy `hosts/acer-swift/default.nix` to `hosts/<hostname>/default.nix`.
2. Generate that machine's hardware file into the new directory:

   ```bash
   sudo nixos-generate-config --show-hardware-config \
     > hosts/<hostname>/hardware-configuration.nix
   ```

3. Set the new host's bootloader and its original `system.stateVersion`.
4. Add one `mkWorkLaptop` entry in `flake.nix`.
5. Build before switching:

   ```bash
   nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel --dry-run
   sudo nixos-rebuild switch --flake .#<hostname>
   ```

Never reuse another laptop's hardware UUIDs. Do not bump `system.stateVersion`
or `home.stateVersion` during routine upgrades.

## Deliberate security boundaries

The container module is imported explicitly because membership in the Docker
group is root-equivalent. Remove `../../modules/containers.nix` from a host that
does not need kind.

tcpdump is installed without a capability wrapper; use `sudo tcpdump` when a
capture requires privilege. No credentials, private keys, tokens, Wi-Fi/VPN
secrets or precise location coordinates belong in ordinary Nix expressions.

Only selected proprietary packages are allowed. Flatpak and imperative Cargo or
Conda installations are not part of the workstation state. Project-specific
tool versions should be pinned by each project's flake/dev shell when needed.

Weekly garbage collection retains generations for 14 days, preserving a useful
rollback window.

## Checks

```bash
nix fmt
nix flake check
nix build .#nixosConfigurations.acer-swift.config.system.build.toplevel --dry-run
```
