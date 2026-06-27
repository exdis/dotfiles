{ inputs, pkgs, ... }:
{
  home-manager.users.exdis = {
    # import the home manager module (also supplies the default `noctalia` package)
    imports = [
      inputs.noctalia.homeModules.default
    ];

    # noctalia v5: option renamed noctalia-shell -> noctalia.
    # Do NOT use lib.mkForce here, or it would wipe the package mkDefault
    # set by homeModules.default and the binary/validation would be skipped.
    programs.noctalia = {
      enable = true;

      # Alabaster — was v4 `colors`. v5's parseCommunityPaletteJson REQUIRES a
      # top-level `dark` object that ALSO contains a `terminal` section; a flat
      # object (or one missing `terminal`) is silently rejected and noctalia
      # falls back to the builtin palette. `light` is omitted -> the parser
      # defaults it to `dark` (theme.mode is fixed to "dark" anyway).
      customPalettes.alabaster =
        let
          dark = {
            # --- Material palette: drives the bar/shell colors ---
            # Error
            mError = "#e06c75"; # base08
            mOnError = "#0b0c0d"; # base00

            # Primary (main accent)
            mPrimary = "#61afef"; # base0D
            mOnPrimary = "#0b0c0d"; # base00

            # Secondary (softer accent)
            mSecondary = "#56b6c2"; # base0C
            mOnSecondary = "#0b0c0d"; # base00

            # Tertiary (highlight / emphasis)
            mTertiary = "#c678dd"; # base0E
            mOnTertiary = "#0b0c0d"; # base00

            # Surfaces
            mSurface = "#101214"; # base01
            mSurfaceVariant = "#1c1f22"; # base02

            # On-surface text
            mOnSurface = "#e6eef3"; # base05
            mOnSurfaceVariant = "#8b9499"; # base04

            # Hover
            mHover = "#61afef"; # base0D
            mOnHover = "#ffffff"; # base07

            # Outline / shadow
            mOutline = "#5b6268"; # base03
            mShadow = "#000000";

            # --- Terminal section (REQUIRED or the whole palette is rejected).
            # Standard base16 -> ANSI mapping; only affects noctalia's terminal
            # theming, not the bar/shell colors above. ---
            terminal = {
              normal = {
                black = "#0b0c0d"; # base00
                red = "#e06c75"; # base08
                green = "#98c379"; # base0B
                yellow = "#e5c07b"; # base0A
                blue = "#61afef"; # base0D
                magenta = "#c678dd"; # base0E
                cyan = "#56b6c2"; # base0C
                white = "#e6eef3"; # base05
              };
              bright = {
                black = "#5b6268"; # base03
                red = "#e06c75"; # base08
                green = "#98c379"; # base0B
                yellow = "#e5c07b"; # base0A
                blue = "#61afef"; # base0D
                magenta = "#c678dd"; # base0E
                cyan = "#56b6c2"; # base0C
                white = "#ffffff"; # base07
              };
              foreground = "#e6eef3"; # base05
              background = "#0b0c0d"; # base00
              cursor = "#e6eef3"; # base05
              cursorText = "#0b0c0d"; # base00
              selectionFg = "#e6eef3"; # base05
              selectionBg = "#1c1f22"; # base02
            };
          };
        in
        { inherit dark; };

      # v5 TOML settings; deep-merged with noctalia defaults.
      settings = {
        # Select the custom Alabaster palette above.
        theme = {
          mode = "dark";
          source = "custom";
          custom_palette = "alabaster";
        };

        # was general.radiusRatio = 0.2 (v5 scale: 1.0 = default, 0 = square)
        shell.corner_radius_scale = 0.2;

        # was location.name; month-before-day is encoded in the clock format below
        location.address = "Prague, Czechia";

        bar.main = {
          position = "top";
          capsule = false; # was showCapsule = false
          # Align the bar with the tiled windows. margin_ends is the inset at
          # each end of the main axis (left/right for a top bar); setting it to
          # Hyprland general:gaps_out (10) lines the bar's edges up with the tile
          # edges instead of spanning past them. margin_edge is the top gap (also
          # 10 = gaps_out). The v4 margin_h / margin_v keys do not exist in v5.
          margin_ends = 10;
          margin_edge = 10;
          radius = 12;
          # "compact" density approximation (no v5 density key)
          thickness = 28;
          padding = 8;
          widget_spacing = 6;

          start = [ "workspaces" ];
          center = [ "active_window" ];
          end = [
            "sysmon_cpu"
            "sysmon_ram"
            "sysmon_net_rx"
            "sysmon_net_tx"
            "network"
            "bluetooth"
            "tray"
            "clock"
            "control-center"
          ];
        };

        dock.enabled = false;

        widget = {
          workspaces = {
            display = "id"; # was labelMode = "index"
            hide_when_empty = false; # was hideUnoccupied = false
          };
          tray.drawer = false; # was drawerEnabled = false
          # Show the NixOS logo on the control-center button instead of the
          # default noctalia glyph (the "owl"). custom_image_colorize stays
          # false so the snowflake keeps its real colors.
          "control-center".custom_image =
            "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          clock = {
            format = "{:%H:%M %a %d %b}"; # was "HH:mm ddd dd MMM"
            vertical_format = "{:%H %M}"; # was "HH mm"
          };
          # one v4 SystemMonitor (load + network) -> named sysmon instances
          sysmon_cpu = {
            type = "sysmon";
            stat = "cpu_usage";
          };
          sysmon_ram = {
            type = "sysmon";
            stat = "ram_pct";
          };
          sysmon_net_rx = {
            type = "sysmon";
            stat = "net_rx";
          };
          sysmon_net_tx = {
            type = "sysmon";
            stat = "net_tx";
          };
        };
      };
    };
  };
}
