{ pkgs, ... }:

{
  # Compatibility for vendor CLIs and downloaded observability agents shipped
  # as conventional dynamically linked Linux binaries.
  programs.nix-ld.enable = true;
  programs.java.enable = true;

  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 524288;
    "fs.inotify.max_user_instances" = 512;
  };

  documentation = {
    dev.enable = true;
    man.cache.enable = true;
  };
  environment.systemPackages = with pkgs; [
    man-pages
    man-pages-posix
  ];
}
