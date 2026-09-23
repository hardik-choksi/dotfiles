{
  lib,
  pkgs,
  primaryUser,
  ...
}:

{
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Kolkata";
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

  users.users.${primaryUser} = {
    isNormalUser = true;
    description = primaryUser;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  # Install Zsh and make it the login shell. User configuration such as
  # ~/.zshrc remains mutable and is intentionally not managed here.
  programs.zsh.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.optimise.automatic = true;

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "claude-code"
      "cursor"
      "google-antigravity-cli"
      "obsidian"
      "postman"
      "slack"
      "vscode"
    ];

  environment.systemPackages = with pkgs; [
    curl
    git
    openssh
    vim
    wget
  ];

  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  boot.loader.systemd-boot.configurationLimit = 5;
}
