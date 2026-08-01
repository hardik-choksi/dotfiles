{ config, pkgs, antigravity-nix, ... }:

{
  imports = [ ./plasma.nix ];

  home.username = "hardik";
  home.homeDirectory = "/home/hardik";
  home.stateVersion = "24.05"; # whatever matches your install, don't change later

  home.packages = with pkgs; [
    go
    # Latest Node LTS. Node 24 (Krypton) is the current Active LTS until
    # 2027-06; 22 dropped to Maintenance. Pinned explicitly rather than using
    # the bare `nodejs` alias, which will drift to 26 when that goes LTS.
    # nvm/fnm are deliberately absent: they download prebuilt binaries that
    # expect /lib64/ld-linux, which NixOS does not have. For per-project
    # versions use a devshell pinning nodejs_20 / nodejs_22 / etc.
    nodejs_24
    xclip
    claude-code
    antigravity-nix.packages.${pkgs.system}.google-antigravity-cli
    git
    zellij
    fzf
    lazydocker  # the `lzd` shell alias below points at this
    nil
  ];

  home.sessionVariables = {
    GOPATH = "$HOME/go";
    GEM_HOME = "$HOME/gems";
  };

  home.sessionPath = [
    "$HOME/.zellij"
    "$HOME/go/bin"
    "$HOME/.local/bin"
    "$HOME/gems/bin"
    "$HOME/.cargo/bin"   # `cargo install` binaries (e.g. dz6)
  ];

  # SSH client config. Pairs with the system-level ssh-agent + ksshaskpass +
  # KWallet setup in configuration.nix:
  #   - AddKeysToAgent yes: once the passphrase is entered (ksshaskpass dialog,
  #     remembered by KWallet), the unlocked key stays in the agent for the rest
  #     of the session, so it isn't re-read on every git op.
  #   - IdentityFile: the single ed25519 key this machine uses.
  # Written as a literal file rather than via programs.ssh because home-manager's
  # ssh module is mid-migration on unstable; a raw config is version-proof. ssh
  # accepts a root-owned, non-world-writable config (a Nix store symlink is
  # exactly that), so StrictModes doesn't complain.
  home.file.".ssh/config".text = ''
    Host *
      AddKeysToAgent yes
      IdentityFile ~/.ssh/id_ed25519
  '';

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = false;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "zsh-fzf-history-search";
        src = pkgs.fetchFromGitHub {
          owner = "joshskidmore";
          repo = "zsh-fzf-history-search";
          rev = "master"; # replace with a real commit hash, see note below
          sha256 = "sha256-6UWmfFQ9JVyg653bPQCB5M4jJAJO+V85rU7zP4cs1VI="; # placeholder, nix will tell you the real one
        };
      }
    ];

    shellAliases = {
      bf = "cd ~/mw/middleware/bifrost";
      cpf = "xclip -selection clipboard";
      lzd = "lazydocker";
    };

    initContent = ''
      # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      # conda, kept as raw shell since it's not a Nix package here
      __conda_setup="$('$HOME/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
      if [ $? -eq 0 ]; then
          eval "$__conda_setup"
      else
          if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
              . "$HOME/miniconda3/etc/profile.d/conda.sh"
          else
              export PATH="$HOME/miniconda3/bin:$PATH"
          fi
      fi
      unset __conda_setup
    '';
  };

}
