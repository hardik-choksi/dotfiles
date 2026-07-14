# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."hardik" = {
    isNormalUser = true;
    description = "hardik";
    # NOTE: "docker" is effectively root — a member can bind-mount the host
    # filesystem into a privileged container and escalate. This is inherent to
    # the Docker daemon socket on any distro, not a NixOS quirk. It is the
    # standard setup and is what kind requires.
    extraGroups = [ "networkmanager" "wheel" "docker" "pcap" ];
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # ZSH
  programs.zsh.enable = true;

  users.users.hardik.shell = pkgs.zsh;

  # Docker engine (the OSS daemon — not Docker Desktop, which isn't packaged
  # for NixOS anyway). Rootful: kind wants privileged containers and native
  # bridge networking, and rootless docker + kind needs cgroup-delegation
  # wrangling that is known to be flaky on NixOS.
  virtualisation.docker.enable = true;

  # kind's default inotify limits are too low for multi-node clusters and pods
  # fail with "too many open files". See kind's Known Issues.
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 524288;
    "fs.inotify.max_user_instances" = 512;
  };

  # Java. This installs the JDK *and* sets JAVA_HOME, which merely putting the
  # package in systemPackages would not do. `jdk` is currently JDK 21 (LTS).
  programs.java.enable = true;

  # Let tcpdump capture without sudo. Packet capture needs CAP_NET_RAW, so on
  # NixOS the binary must be wrapped -- otherwise every capture needs root.
  # Gated on the "pcap" group so this isn't granted system-wide. Same idiom
  # NixOS's own wireshark module uses for dumpcap.
  users.groups.pcap = { };
  security.wrappers.tcpdump = {
    source = "${pkgs.tcpdump}/bin/tcpdump";
    capabilities = "cap_net_raw,cap_net_admin+eip";
    owner = "root";
    group = "pcap";
    permissions = "u+rx,g+x";
  };

  # `vi` is muscle memory, but nixpkgs' vim provides only a `vim` binary --
  # there is no `vi`, so it would be command-not-found. Alias it, and make vim
  # the default $EDITOR.
  programs.vim = {
    enable = true;
    defaultEditor = true;
  };
  environment.shellAliases.vi = "vim";

  # Flatpak, as an escape hatch for apps nixpkgs doesn't carry (or has dropped
  # -- OpenLens, for instance, is still on Flathub). The module asserts that
  # xdg.portal.enable is true; plasma6 already sets it, so nothing to add.
  #
  # It does NOT configure any remote, so after the first rebuild you must add
  # Flathub once, imperatively:
  #
  #   flatpak remote-add --if-not-exists flathub \
  #     https://flathub.org/repo/flathub.flatpakrepo
  #
  # Anything installed this way lives outside Nix: not declared by this flake,
  # not rolled back by nixos-rebuild.
  services.flatpak.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Iosevka Nerd Font, set as the system default monospace font
  fonts.packages = with pkgs; [
    nerd-fonts.iosevka
  ];
  fonts.fontconfig.defaultFonts.monospace = [ "Iosevka Nerd Font Mono" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # vim is installed by programs.vim above (which also sets EDITOR and the
    # `vi` alias), so it is not repeated here.
    wget
    keepassxc
    alacritty
    pkgs.zed-editor
    go
    fastfetch
    brave

    # Targets of the Plasma shortcuts in plasma.nix — without these the
    # bindings are dead keys (KDE resolves them by .desktop file name).
    kdePackages.konsole    # Meta+T
    kdePackages.spectacle  # Meta+Shift+R
    slack                  # Meta+S  (unfree; needs allowUnfree above)

    # Kubernetes
    kubectl
    kubernetes-helm  # NB: NOT `helm` -- that attribute is a polyphonic
                     # synthesizer. This is the Kubernetes package manager.
    kubectx          # provides both kubectx and kubens
    stern            # multi-pod log tailing
    k9s
    kind          # spins clusters up in Docker; needs virtualisation.docker
    freelens-bin  # NB: the attribute is freelens-bin, not freelens.
                  # This replaces OpenLens, which was removed from nixpkgs --
                  # Mirantis pulled Lens's source in 2023 so it could no longer
                  # be rebuilt, and the project is deprecated. FreeLens is the
                  # community fork that succeeded it (MIT).

    # Database
    dbeaver-bin   # NB: the attribute is dbeaver-bin. Plain `dbeaver` does not
                  # exist and has no alias, so it is a hard eval error.

    # API
    postman       # unfree; needs allowUnfree above

    # Editors
    vscode        # unfree; needs allowUnfree above
    code-cursor   # NB: the attribute is code-cursor, not `cursor` (which does
                  # not exist and has no alias). The binary is still `cursor`.
                  # Unfree; needs allowUnfree above.

    # Build toolchain. NixOS ships no compiler by default -- if you build
    # anything outside a devshell you need these explicitly.
    gcc
    gnumake
    pkg-config

    # ELF / binary analysis
    binutils   # readelf, objdump, nm, strings, ar, ld
    elfutils   # the eu-* variants: eu-readelf, eu-objdump, eu-stack
    patchelf   # rewrite ELF interpreter/RPATH -- the standard NixOS fix for
               # running foreign prebuilt binaries
    gdb
    ltrace
    strace
    radare2
    pahole     # struct layout from DWARF
    file
    hexyl      # quick hex dumps (xxd itself comes with vim, already enabled)
               # dz6 (the TUI hex editor) is not in nixpkgs and is installed
               # by hand via `cargo install dz6`.

    # Android
    android-tools  # adb + fastboot. NB: there is no `fastboot` attribute.

    # CLI
    curl        # NOT in NixOS's default system path, despite being on every
                # other distro. Genuinely absent unless declared.
    openssh     # ssh, scp, ssh-keygen
    ripgrep
    gh
    jq
    bat
    btop
    tree
    unzip
    nmap
    python3

    # Networking. NixOS's default path has no ping, ip, ss or traceroute, so
    # these are not as redundant as they look on a normal distro. There is no
    # `nettools`/`net-tools` in nixpkgs -- the old ifconfig/netstat/route
    # package is deprecated upstream; use iproute2's `ip` and `ss` instead.
    dnsutils      # dig, nslookup, host
    iputils       # ping
    iproute2      # ip, ss
    traceroute
    tcpdump
    mtr
    whois
    socat
    ethtool
    netcat-openbsd  # the default path's `netcat` is the libressl one; this is
                    # the OpenBSD nc most people mean.

    # Media
    mpv
    stremio-linux-shell  # NB: the attribute is stremio-linux-shell, and the
                         # binary is `stremio`. Plain `stremio` was removed in
                         # Feb 2026 (it pulled in the vulnerable, outdated qt5
                         # webengine) and is now a `throw`, which points here.
                         # It bundles the streaming server; there is no
                         # separate service to enable.
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}
