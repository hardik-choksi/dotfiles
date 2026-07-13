{ ... }:

# KDE Plasma configuration, ported from ~/dotfiles/kde.
#
# Only genuinely-customised settings live here. Deliberately omitted:
#   - khotkeysrc: was pure KDE boilerplate (Konqueror gestures + disabled
#     examples) with no custom hotkeys; KHotkeys is gone in Plasma 6 anyway.
#     The app launchers are in shortcuts."services/<app>.desktop" below.
#   - kwinrc [Tiling][<uuid>] blocks: keyed by per-machine desktop/screen
#     UUIDs, meaningless on a different host. Re-draw tiles with Meta+T.
#   - Appearance. The Ubuntu box's look (Andromeda look-and-feel, YAMIS icons,
#     MateriaDark colours, Apple-Aurora window decorations, the Aura Glow
#     effect) is hand-installed under ~/.local/share and is not packaged in
#     nixpkgs, so this box gets stock Breeze. Theme it by hand if you want it.
{
  programs.plasma = {
    enable = true;

    shortcuts = {
      kwin = {
        # Vim-style desktop switching
        "Switch One Desktop to the Left" = "Meta+H";
        "Switch One Desktop to the Right" = "Meta+L";
        "Window One Desktop to the Left" = "Meta+Shift+H";
        "Window One Desktop to the Right" = "Meta+Shift+L";

        "Switch to Desktop 1" = "Meta+1";
        "Switch to Desktop 2" = "Meta+2";
        "Switch to Desktop 3" = "Meta+3";
        "Switch to Desktop 4" = "Meta+4";
        "Switch to Desktop 5" = "Meta+5";

        # Window management
        "Window Close" = [ "Alt+Q" "Alt+F4" ];
        "Window Maximize" = "Meta+PgUp";
        "Window Minimize" = "Meta+PgDown";

        # Effects / overview
        "Overview" = "Meta+O";
        "Cycle Overview" = "Meta+Tab";
        "Grid View" = "Meta+G";
        "Cube" = "Meta+C";
        "Show Desktop" = "Meta+D";
      };

      # Application launchers
      "services/org.kde.konsole.desktop"."_launch" = "Meta+T";
      "services/org.kde.krunner.desktop"."_launch" = [ "Meta+R" "Alt+Space" ];
      "services/slack.desktop"."_launch" = "Meta+S";
      "services/org.kde.spectacle.desktop"."RecordRegion" = "Meta+Shift+R";
    };

    kwin = {
      virtualDesktops = {
        rows = 1;
        names = [ "Web" "code" "New Desktop" "New Desktop" "New Desktop" ];
      };

      effects = {
        blur = {
          enable = true;
          noiseStrength = 14;
        };
        translucency.enable = true;
        wobblyWindows.enable = true;
      };

      nightLight = {
        enable = true;
        mode = "location";
        location = {
          latitude = "22.21";
          longitude = "71.42";
        };
        temperature.night = 3800;
      };
    };

    fonts = {
      general = { family = "Iosevka Nerd Font"; pointSize = 13; };
      fixedWidth = { family = "IosevkaTermSlab Nerd Font"; pointSize = 11; };
    };

    # Effects with no typed plasma-manager option. (blur, translucency and
    # wobbly windows are set above via kwin.effects — don't also set their
    # [Plugins] keys here, that would be a duplicate write to the same key.)
    # Contrast is on by default in Plasma 6.
    configFile.kwinrc = {
      "Plugins" = {
        cubeEnabled = true;
        mousemarkEnabled = true;
        sheetEnabled = true;
      };
      "Effect-desktopgrid".LayoutMode = 1;
      "Tiling".padding = 4;
    };
  };

  # Konsole. plasma-manager's konsole module owns konsolerc, so configure it
  # through that rather than writing the file directly.
  programs.konsole = {
    enable = true;
    defaultProfile = "Maaru";
    profiles.Maaru = {
      name = "Maaru";
      font = {
        name = "IosevkaTerm Nerd Font Mono";
        size = 12;
      };
      # The Ubuntu box used a hand-installed "kubuntu-black" scheme, which is
      # not packaged. Breeze is the closest stock dark scheme.
      colorScheme = "Breeze";
      extraConfig."Appearance".BoldIntense = "false";
    };
  };
}
