# dz6 — a vim-inspired, TUI-based hex editor.
#
# Not in nixpkgs, so it's built from crates.io here. Upstream:
#   https://github.com/mentebinaria/dz6
#
# HASHES ARE PLACEHOLDERS. Nix cannot compute them without building, and this
# was authored on a machine with no Nix. On the first `nixos-rebuild` both will
# fail with a "hash mismatch" that prints the correct value — paste each in.
# Expect to do this twice: once for `hash`, then once for `cargoHash`.
{
  lib,
  rustPlatform,
  fetchCrate,
}:

rustPlatform.buildRustPackage rec {
  pname = "dz6";
  version = "0.7.0";

  src = fetchCrate {
    inherit pname version;
    hash = lib.fakeHash;
  };

  cargoHash = lib.fakeHash;

  meta = {
    description = "Vim-inspired, TUI-based hexadecimal editor";
    homepage = "https://github.com/mentebinaria/dz6";
    license = lib.licenses.gpl3Plus;
    mainProgram = "dz6";
    platforms = lib.platforms.linux;
  };
}
