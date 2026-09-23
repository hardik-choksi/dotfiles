{ hostname, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core.nix
    ../../modules/desktop.nix
    ../../modules/development.nix
    ../../modules/containers.nix
    ../../modules/home-manager.nix
  ];

  networking.hostName = hostname;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # First-install compatibility baseline; do not bump during routine upgrades.
  system.stateVersion = "26.05";
}
