{
  inputs,
  pkgs,
  primaryUser,
  ...
}:

{
  home.username = primaryUser;
  home.homeDirectory = "/home/${primaryUser}";
  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    # Editors and work applications
    vscode
    code-cursor
    zed-editor
    kdePackages.kate
    obsidian
    dbeaver-bin
    postman
    slack
    element-desktop
    telegram-desktop
    keepassxc
    brave
    codex
    claude-code
    inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-cli

    # Language runtimes and build toolchain
    go
    nodejs_24
    python3
    rustc
    cargo
    gcc
    gnumake
    pkg-config

    # Kubernetes and containers
    kubectl
    kubernetes-helm
    kubectx
    stern
    k9s
    kind
    freelens-bin
    lazydocker

    # ELF, tracing and observability. glibc.bin provides ldd; the runtime linker
    # honors LD_PRELOAD, while patchelf/elfutils/binutils cover ELF inspection.
    glibc.bin
    liburing
    liburing.bin
    liburing.dev
    liburing.man
    binutils
    elfutils
    patchelf
    gdb
    ltrace
    strace
    radare2
    pahole
    file
    hexyl
    valgrind
    bpftrace
    perf
    lsof
    procps
    psmisc
    sysstat

    # Networking and diagnostics
    dnsutils
    iputils
    iproute2
    traceroute
    tcpdump
    mtr
    whois
    socat
    ethtool
    netcat-openbsd
    nmap

    # CLI utilities
    ripgrep
    gh
    jq
    bat
    btop
    tree
    unzip
    fzf
    zellij
    fastfetch
    nil
    xclip

    # Device, media and disk tools (Stremio intentionally omitted)
    android-tools
    mpv
    qbittorrent
    caligula
    popsicle
    kdePackages.kcalc
  ];

  programs.home-manager.enable = true;
}
