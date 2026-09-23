{ lib, primaryUser, ... }:

{
  # This opt-in profile is root-equivalent because kind needs rootful Docker.
  virtualisation.docker.enable = true;
  users.users.${primaryUser}.extraGroups = [ "docker" ];

  # Keep kind's inter-node L2 traffic out of host bridge firewall hooks without
  # disabling reverse-path filtering for ordinary routed host traffic.
  boot.kernelModules = [ "br_netfilter" ];
  boot.kernel.sysctl = {
    "net.bridge.bridge-nf-call-iptables" = lib.mkDefault 0;
    "net.bridge.bridge-nf-call-ip6tables" = lib.mkDefault 0;
  };
}
