# NixOS Configuration

A complete, declarative NixOS + KDE Plasma 6 workstation for backend/observability
development. Everything below — packages, desktop look, shortcuts, dev toolchain,
SSH/KWallet — is reproduced from these four files on any machine with one
`nixos-rebuild`.

This directory is the source of truth. It is **live** — booted and running on an
Acer Swift Go 14 (Intel i5). The committed `hardware-configuration.nix` is that
machine's real hardware scan. The whole set is verified to evaluate cleanly:

```bash
nix build .#nixosConfigurations.nixos.config.system.build.toplevel --dry-run
```

exits 0, so every module option and package attribute resolves.

## Files

| File | Contents |
|------|----------|
| `flake.nix` | Inputs: nixpkgs (unstable), home-manager, plasma-manager, antigravity-nix |
| `configuration.nix` | System: KDE Plasma 6, SDDM, pipewire, Docker, SSH/KWallet, the system package set, the user |
| `home.nix` | home-manager: zsh + p10k, shell aliases, per-user dev packages, SSH client config |
| `plasma.nix` | KDE look & feel via plasma-manager (theme, icons, panel, shortcuts, Konsole) |
| `hardware-configuration.nix` | **The Acer's scan. Regenerate on any other machine.** |

---

## What you get

### The desktop (how it looks)

- **KDE Plasma 6 on Wayland**, SDDM login manager.
- **Andromeda** global look-and-feel — a dark theme that also carries its own
  colour scheme, Plasma desktop style and window decoration.
- **YAMIS** monochrome icon theme, layered on **Papirus-Dark** as its base.
- **Bottom panel** transcribed from the old Ubuntu box: app launcher (kickoff),
  task manager, four system-monitor widgets (network / memory / swap / per-core
  CPU), system tray, a 24-hour clock, a sticky note and a show-desktop button.
- **5 virtual desktops** with vim-style switching.
- **Iosevka Nerd Font** as the system monospace.
- **Konsole** profile "Maaru": IosevkaTerm Nerd Font Mono 12pt, **White on Black**
  colour scheme.
- **Night light** and KWin effects configured declaratively.

### Keyboard shortcuts (from `plasma.nix`)

| Shortcut | Action |
|----------|--------|
| `Ctrl+Alt+T` | Open Konsole |
| `Meta+R` / `Alt+Space` | KRunner |
| `Meta+S` | Slack |
| `Meta+Shift+R` | Spectacle region screenshot |
| `Meta+T` | Tiling editor (KWin) |
| `Meta+O` | Overview · `Meta+G` Grid · `Meta+Tab` cycle |
| `Meta+H` / `Meta+L` | Switch desktop left / right |
| `Meta+Shift+H` / `Meta+Shift+L` | Move window to desktop left / right |
| `Meta+1`…`Meta+5` | Jump to desktop 1–5 |
| `Meta+PgUp` / `Meta+PgDown` | Maximize / minimize window |
| `Meta+D` | Show desktop · `Alt+Q` / `Alt+F4` close window |

### System setup (`configuration.nix`)

- **Networking:** NetworkManager. **Audio:** PipeWire (ALSA + Pulse, 32-bit
  support). **Printing:** CUPS. **Locale:** `en_US.UTF-8` with `en_IN` regional
  units, `Asia/Kolkata` timezone.
- **Docker** (rootful) with `hardik` in the `docker` group — required by `kind`.
- **nix-ld** for running some foreign prebuilt binaries.
- **Flatpak** enabled as an escape hatch (no remote configured — add Flathub by
  hand, see below).
- **tcpdump** wrapped with `CAP_NET_RAW` gated on the `pcap` group, so packet
  capture works without `sudo`.
- **Java** via `programs.java` (JDK 21 LTS, sets `JAVA_HOME`).
- **Automatic GC** weekly (keeps only the current generation) + store
  deduplication; boot menu capped at 5 entries.
- **SSH agent + KWallet** so a key passphrase is typed once and remembered
  across reboots — see [SSH keys & KWallet](#ssh-keys--kwallet) below.
- **Shell:** zsh (system default) with a `vi → vim` alias and `zed → zeditor`.

### Packages

**Shell & CLI** — `curl` · `wget` · `ripgrep` · `jq` · `bat` · `btop` · `tree` ·
`unzip` · `fzf` · `zellij` · `fastfetch` · `gh` · `git` · `openssh` · `python3` ·
`nodejs_24` · `go` · `xclip`

**Editors & IDEs** — VS Code · Cursor (`code-cursor`) · Zed (`zed-editor`) ·
Kate · Vim · Obsidian (notes) · `claude-code` · Google Antigravity CLI

**Kubernetes / cloud** — `kubectl` · `kubernetes-helm` · `kubectx`/`kubens` ·
`stern` (multi-pod logs) · `k9s` · `kind` (clusters in Docker) · `freelens-bin`
(the OpenLens successor) · `lazydocker`

**Database & API** — DBeaver (`dbeaver-bin`) · Postman

**Debugging / binary analysis** — `gdb` · `strace` · `ltrace` · `radare2` ·
`binutils` (readelf/objdump/nm) · `elfutils` · `patchelf` · `pahole` · `file` ·
`hexyl`

**Networking / diagnostics** — `dnsutils` (dig) · `iputils` (ping) · `iproute2`
(ip, ss) · `traceroute` · `tcpdump` · `mtr` · `whois` · `socat` · `ethtool` ·
`netcat-openbsd` · `nmap`

**Build toolchain** — `gcc` · `gnumake` · `pkg-config` (NixOS ships no compiler
by default)

**Apps** — Firefox · Brave · Slack · KeePassXC · `mpv` · Stremio
(`stremio-linux-shell`) · KCalc · `android-tools` (adb/fastboot) · `caligula` +
`popsicle` (USB/SD imaging)

**Shell env** — zsh + `oh-my-zsh` (git plugin) + **powerlevel10k** prompt +
`zsh-fzf-history-search` + syntax highlighting. Aliases: `bf` (bifrost dir),
`cpf` (clipboard), `lzd` (lazydocker), `vi`, `zed`. `GOPATH=~/go`,
`GEM_HOME=~/gems`.

---

## SSH keys & KWallet

The passphrase-per-git-op annoyance is solved declaratively. On this machine an
SSH key passphrase is entered **once**, stored in KWallet, and never asked for
again — not even after a reboot.

### How it works

```
git fetch ──▶ ssh ──▶ ssh-agent (empty?) ──▶ ksshaskpass GUI ──▶ KWallet
   │              (SSH_AUTH_SOCK)      (SSH_ASKPASS)        (stores passphrase)
   └── on later boots: KWallet auto-unlocks at login (PAM) ──▶ ksshaskpass
       reads the passphrase back silently ──▶ key re-added, no prompt
```

Four cooperating pieces, all in `configuration.nix`:

1. **`programs.ssh.startAgent`** — runs OpenSSH's `ssh-agent` as a per-user
   systemd service and exports `SSH_AUTH_SOCK`. This is the single agent that
   holds unlocked keys. (Do **not** also enable gnome-keyring's ssh component or
   `gpg-agent`'s SSH support — all three fight over the same socket.)
2. **`programs.ssh.enableAskPassword`** + the Plasma 6 module — point
   `SSH_ASKPASS` at **`ksshaskpass`**, a Qt dialog that reads/writes the
   passphrase from **KWallet**.
3. **`SSH_ASKPASS_REQUIRE = "prefer"`** — without it, `ssh-add` run from a
   terminal uses the tty prompt and never calls the GUI askpass. This is the #1
   reason people find "ksshaskpass never shows up".
4. **`security.pam.services.{login,sddm}.kwallet.enable`** — auto-unlock KWallet
   at login (when the wallet password equals the login password), so ksshaskpass
   can read the passphrase back with no interaction on later boots.

`home.nix` adds `~/.ssh/config` with `AddKeysToAgent yes` and the `IdentityFile`,
so the unlocked key stays in the agent for the rest of the session.

### First-time use

On the **first** `git fetch/pull/push` after applying this config, a KDE dialog
pops up asking for the key passphrase — **tick "Remember"** and enter it once.
That writes it into KWallet. From then on you're never asked again.

If the ksshaskpass dialog does *not* appear (rare PAM-timing issue), the fallback
is fine: you'll get one prompt per login instead of one per git op. Make sure the
KWallet password equals your login password so PAM auto-unlock fires.

### Using KWallet as a developer

KWallet is a session-wide encrypted secret store (KDE's answer to gnome-keyring /
macOS Keychain), unlocked once at login. Beyond SSH it's genuinely useful in an
observability/backend workflow:

- **SSH key passphrases** — as above (the headline win).
- **Git credential helper.** For any HTTPS remotes or registry logins, KDE's
  `git-credential-libsecret` stores tokens in KWallet instead of plaintext
  `~/.git-credentials`. Point git at it with
  `git config --global credential.helper libsecret`.
- **The Secret Service API.** KWallet exposes the freedesktop
  `org.freedesktop.secrets` D-Bus interface, so tools that speak it store
  secrets there automatically — e.g. **Docker/`docker login`** via
  `docker-credential-secretservice`, **`skopeo`**/registry creds, cloud CLIs, and
  DBeaver/database clients that opt into the system keyring. One unlock covers
  all of them.
- **`kwallet-query`** — script against the wallet from the CLI:
  `kwallet-query -l kdewallet` to list, `-r <key> -f <folder>` to read. Handy for
  pulling an API token into a shell without hardcoding it.
- **App passwords** — Brave/Chromium, KMail, Nextcloud, VPN and Wi-Fi secrets all
  land in KWallet, so they survive declaratively-rebuilt systems.

Treat it as the one place session secrets live: unlocked with your login, wiped
from memory on logout, encrypted (Blowfish/GPG) at rest.

---

## ⚠️ Regenerate `hardware-configuration.nix` on a different machine

The committed `hardware-configuration.nix` is the Acer Swift Go 14's real scan —
its disk UUIDs, swap device and kernel modules. It is correct for *that* box and
wrong for any other. To reuse this config on a **new** machine, regenerate it
first, or the system will not boot:

```bash
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

Nothing else in the config is machine-specific.

---

## Notable package quirks

A few attribute names are not what you'd naively guess (these are the ones that
would be hard eval errors or silent surprises):

- **`dbeaver-bin`**, not `dbeaver` — the plain attribute doesn't exist.
- **`freelens-bin`**, not `openlens` — OpenLens was removed from nixpkgs
  (Mirantis pulled Lens's source in 2023). [FreeLens](https://github.com/freelensapp/freelens)
  is the MIT community fork that succeeded it.
- **`stremio-linux-shell`**, not `stremio` — plain `stremio` was removed
  (Feb 2026, vulnerable Qt5 WebEngine) and now `throw`s pointing here. Binary is
  still `stremio`.
- **`kubernetes-helm`**, not `helm` — `helm` is a polyphonic synthesizer.
- **`code-cursor`**, not `cursor` — binary is still `cursor`.
- **No `nvm`/`fnm`.** They download prebuilt Node binaries expecting
  `/lib64/ld-linux`, which NixOS lacks. `home.nix` pins `nodejs_24` (Active LTS);
  for per-project versions use a devshell pinning `nodejs_20`/`nodejs_22`.
- **`balena-etcher` is gone** — removed from nixpkgs (bundled Electron went EOL
  repeatedly). `caligula` (TUI) + `popsicle` (GUI) replace it.

### `dz6` (hex editor) — installed by hand

`dz6` isn't in nixpkgs: `cargo install dz6` (lands in `~/.cargo/bin`). It works
because cargo compiles against the Nix toolchain — unlike a *prebuilt* binary,
which would fail on the missing `/lib64/ld-linux`.

### Docker is effectively root

`hardik` is in the `docker` group; membership lets a user bind-mount the host FS
into a privileged container. Inherent to the Docker socket on any distro, and
what `kind` needs.

---

## Usage

### Rebuilding this machine (the Acer)

```bash
sudo nixos-rebuild switch --flake .#nixos
```

### Installing on a fresh machine (no SSH/GPG keys yet)

A brand-new box has **no SSH key**, so it cannot clone via `git@github.com`.
That's fine — nothing in the first rebuild needs a key (Nix fetches every flake
input over HTTPS), and the SSH-agent/KWallet convenience only *exists after* the
config is applied. So keys are the **last** step, not the first. Do it in this
order:

**0. Install base NixOS** from the ISO (partition + `nixos-install`), reboot into
it. You get a minimal system with `nix` and `git`.

**1. Get this config over HTTPS** (no key needed):

```bash
# Public repo — anonymous clone:
nix-shell -p git --run 'git clone https://github.com/hardik-choksi/dotfiles.git ~/dotfiles'

# Private repo — authenticate in the browser first (no SSH involved):
nix-shell -p gh git --run 'gh auth login && gh repo clone hardik-choksi/dotfiles ~/dotfiles'

cd ~/dotfiles/nixos
```

**2. Regenerate the hardware scan** — REQUIRED, or the system won't boot:

```bash
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

**3. First build** — installs everything and turns on ssh-agent + ksshaskpass +
KWallet:

```bash
sudo nixos-rebuild switch --flake .#nixos
```

Expect this to pull a lot (VS Code, Cursor, Postman, DBeaver, FreeLens, Stremio
and the full KDE stack are all sizeable).

**4. Log out and back in** (or reboot). The `docker`/`pcap` group memberships,
KWallet auto-unlock and the ssh-agent only bind to a fresh session. When KWallet
first prompts, **set its password equal to your login password** so PAM
auto-unlocks it going forward.

**5. Create your SSH key** — imperative and per-machine; private keys are *never*
committed to this repo:

```bash
ssh-keygen -t ed25519 -C "dev@middleware.io"
# Set a passphrase when asked — that's the one KWallet will remember.
```

**6. Put the public key on GitHub** — easiest via `gh` (browser OAuth, no SSH):

```bash
gh auth login                                            # if not already
gh ssh-key add ~/.ssh/id_ed25519.pub --title "$(hostname)"
# ...or copy it and paste into github.com/settings/keys:
cat ~/.ssh/id_ed25519.pub
```

**7. Switch this repo's remote from HTTPS to SSH** so future push/pull use the
key (and trigger KWallet caching):

```bash
git remote set-url origin git@github.com:hardik-choksi/dotfiles.git
```

**8. First git over SSH** → the ksshaskpass dialog appears → enter the passphrase,
tick **Remember**. Done — you're never asked again, even after a reboot (see
[SSH keys & KWallet](#ssh-keys--kwallet)).

**9. Optional — Flathub remote** (the module configures no remote):

```bash
flatpak remote-add --if-not-exists flathub \
  https://flathub.org/repo/flathub.flatpakrepo
```

#### Optional: GPG for signed commits

This config does **not** require GPG — nothing here signs commits, so you can skip
it entirely at bootstrap. If you want verified commits:

```bash
gpg --full-generate-key                       # ed25519, or RSA 4096
gpg --armor --export <KEY_ID>                 # paste into github.com/settings/keys (GPG)
git config --global user.signingkey <KEY_ID>
git config --global commit.gpgsign true
```

Caveat: do **not** enable `programs.gnupg.agent.enableSSHSupport` alongside the
ssh-agent above — both claim `SSH_AUTH_SOCK` and will fight. Keep GPG for signing
only and leave SSH auth to ssh-agent. For GPG passphrase caching on Plasma, add
`pinentry-qt`.

### Checking changes before you rebuild

```bash
nix build .#nixosConfigurations.nixos.config.system.build.toplevel --dry-run
```

Evaluates every option and package without downloading or compiling anything —
catches typo'd options and nonexistent attributes in seconds.
