{ pkgs, ... }:

# KDE Plasma configuration, ported from ~/dotfiles/kde.
#
# Only genuinely-customised settings live here. Deliberately omitted:
#   - khotkeysrc: was pure KDE boilerplate (Konqueror gestures + disabled
#     examples) with no custom hotkeys; KHotkeys is gone in Plasma 6 anyway.
#     The app launchers are in shortcuts."services/<app>.desktop" below.
#   - kwinrc [Tiling][<uuid>] blocks: keyed by per-machine desktop/screen
#     UUIDs, meaningless on a different host. Re-draw tiles with Meta+T.
#   - The "Aura Glow" KWin effect (Schneegans' Burn-My-Windows). It's a KWin
#     scripted effect, and plasma-manager has no option to enable third-party
#     KWin effects (they need kpackagetool6 registration, not just a file in
#     an XDG path). Left hand-installed.
#
# The rest of the Ubuntu look IS reproduced below -- see the `let` block, which
# packages the three themes that aren't in nixpkgs, and workspace.* / the
# window-decoration config, which SELECT them. MateriaDark's colours come from
# the packaged `materia-kde-theme`.
let
  # Andromeda global look-and-feel (github.com/EliverLara/Andromeda-kde).
  # Pure QML/SVG/ini data -- no build, just copy the trees KDE looks for into
  # $out/share. Pinned to a commit so the hash is stable.
  andromeda-kde = pkgs.stdenvNoCC.mkDerivation {
    pname = "andromeda-kde";
    version = "0-unstable-2025-01-14";
    src = pkgs.fetchFromGitHub {
      owner = "EliverLara";
      repo = "Andromeda-kde";
      rev = "c97ba4265fe7c1e7b8d67437d1b807cefb80775d";
      hash = "sha256-+OGtEjTCo++JUTUY3Hiplc/KlKxeMOEmETcQlvjTWa8=";
    };
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/plasma $out/share/aurorae/themes $out/share/color-schemes
      cp -r plasma/look-and-feel $out/share/plasma/
      cp -r plasma/desktoptheme  $out/share/plasma/
      cp -r aurorae/Andromeda    $out/share/aurorae/themes/
      cp -r color-schemes/.      $out/share/color-schemes/
      runHook postInstall
    '';
  };

  # YAMIS icon theme (github.com/googIyEYES/YAMIS): a single tarball that
  # extracts to a top-level YAMIS/ dir. Monochrome set -- it defines only some
  # icons and Inherits=Papirus-Dark for the rest, so papirus-icon-theme must
  # also be installed (see home.packages selection note below) or icons fall
  # back to broken.
  yamis-icons = pkgs.stdenvNoCC.mkDerivation {
    pname = "yamis-icon-theme";
    version = "0-unstable-2026-02-06";
    src = pkgs.fetchFromGitHub {
      owner = "googIyEYES";
      repo = "YAMIS";
      rev = "24c02f6bb7bcd356e49df22f6942b078b66700fd";
      hash = "sha256-KZXG5XYHhUfgDrxOXT1mS+vbmH9l0uEzfdvOo1+r1TQ=";
    };
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/icons
      tar -xf monochrome-icon-theme.tar.gz -C $out/share/icons
      runHook postInstall
    '';
  };

in
{
  # Make the theme packages discoverable by Plasma. home-manager adds this
  # profile's share/ to XDG_DATA_DIRS, so KDE finds the look-and-feel, icons
  # and colour schemes installed here.
  #   - andromeda-kde: provides the look-and-feel, its plasma desktoptheme AND
  #     its own Andromeda colour scheme (so no separate colours package needed).
  #   - papirus-icon-theme: YAMIS inherits from Papirus-Dark for icons it doesn't
  #     define itself; without it the monochrome set has gaps.
  home.packages = [
    andromeda-kde
    yamis-icons
    pkgs.papirus-icon-theme
  ];

  programs.plasma = {
    enable = true;

    # Appearance selection -- activate the themes packaged in the let block.
    workspace = {
      lookAndFeel = "Andromeda";       # KPlugin Id from its metadata.json
      colorScheme = "Andromeda";       # Andromeda ships its own scheme (its
                                       # color-schemes/Andromeda.colors)
      iconTheme = "YAMIS";             # the folder name KDE keys on
      # Window decoration is deliberately NOT set here: the Andromeda
      # look-and-feel carries its own deco, and plasma-manager warns that
      # setting both fights the LnF. We let Andromeda own the titlebars.
    };

    # Bottom panel (taskbar), transcribed by hand from the Ubuntu box's
    # plasma-org.kde.plasma.desktop-appletsrc -- rc2nix cannot capture panels,
    # so this is the source of truth. Widget order matches the live
    # AppletOrder=370;372;398;396;373;400;395;374;389;399;390.
    #
    # NB: plasma-manager rebuilds panels by running a plasmashell script on
    # activation (delete-all + recreate), so on first apply you may see a
    # transient KDE crash-handler popup -- harmless, the panel still builds.
    # The four systemMonitor widgets use the generic { name; config; } form:
    # their titles + chart faces are set here, but fine sensor/colour details
    # may need a one-time tweak in the widget's settings after first rebuild.
    panels = [
      {
        location = "bottom";
        widgets = [
          "org.kde.plasma.kickoff"        # 370  app launcher
          "org.kde.plasma.icontasks"      # 372  task manager
          # 398  Network Speed (line chart)
          {
            name = "org.kde.plasma.systemmonitor.net";
            config.Appearance = {
              title = "Network Speed";
              chartFace = "org.kde.ksysguard.linechart";
            };
          }
          # 396  Memory Usage (pie chart)
          {
            name = "org.kde.plasma.systemmonitor.memory";
            config.Appearance = {
              title = "Memory Usage";
              chartFace = "org.kde.ksysguard.piechart";
            };
          }
          "org.kde.plasma.marginsseparator"  # 373  spacer
          # 400  Swap Usage (pie chart)
          {
            name = "org.kde.plasma.systemmonitor";
            config.Appearance = {
              title = "Swap Usage";
              chartFace = "org.kde.ksysguard.piechart";
            };
          }
          # 395  Individual Core Usage (bar chart)
          {
            name = "org.kde.plasma.systemmonitor.cpucore";
            config.Appearance = {
              title = "Individual Core Usage";
              chartFace = "org.kde.ksysguard.barchart";
            };
          }
          "org.kde.plasma.systemtray"     # 374  system tray
          # 389  clock, 24-hour
          {
            digitalClock.time.format = "24h";
          }
          "org.kde.plasma.notes"          # 399  sticky note
          "org.kde.plasma.showdesktop"    # 390  show-desktop button
        ];
      }
    ];

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

      ksmserver = {
        "Lock Session" = [ "Screensaver" ]; # Unbind Meta+L so kwin can use it
      };

      plasmashell = {
        # Unbind Meta+1..5 from task manager to allow kwin desktop switching
        "activate task manager entry 1" = [];
        "activate task manager entry 2" = [];
        "activate task manager entry 3" = [];
        "activate task manager entry 4" = [];
        "activate task manager entry 5" = [];
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
