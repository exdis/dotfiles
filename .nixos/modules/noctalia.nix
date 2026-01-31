{ pkgs, inputs, lib, ... }:
{
  home-manager.users.exdis = {
    # import the home manager module
    imports = [
      inputs.noctalia.homeModules.default
    ];

    # configure options
    programs.noctalia-shell = lib.mkForce {
      enable = true;
      # Alabaster
      colors = {
        # Error
        mError = "#e06c75";        # base08
        mOnError = "#0b0c0d";      # base00

        # Primary (main accent)
        mPrimary = "#61afef";      # base0D
        mOnPrimary = "#0b0c0d";    # base00

        # Secondary (softer accent)
        mSecondary = "#56b6c2";    # base0C
        mOnSecondary = "#0b0c0d";  # base00

        # Tertiary (highlight / emphasis)
        mTertiary = "#c678dd";     # base0E
        mOnTertiary = "#0b0c0d";   # base00

        # Surfaces
        mSurface = "#101214";          # base01
        mSurfaceVariant = "#1c1f22";   # base02

        # On-surface text
        mOnSurface = "#e6eef3";        # base05
        mOnSurfaceVariant = "#8b9499"; # base04

        # Hover
        mHover = "#61afef";      # base0D
        mOnHover = "#ffffff";     # base07

        # Outline / shadow
        mOutline = "#5b6268";     # base03
        mShadow = "#000000";
      };
      # colors = {
      #   # Error - using the vibrant red-orange from the taillights
      #   mError = "#ff4500";        # Bright orange-red from taillights
      #   mOnError = "#0a0a0a";      # Deep black from car body

      #   # Primary (main accent) - the glowing taillight core
      #   mPrimary = "#ff6b35";      # Warm orange glow
      #   mOnPrimary = "#0a0a0a";    # Deep black

      #   # Secondary (softer accent) - ambient city lights
      #   mSecondary = "#ff8c42";    # Softer orange from light diffusion
      #   mOnSecondary = "#0a0a0a";  # Deep black

      #   # Tertiary (highlight / emphasis) - bokeh highlights
      #   mTertiary = "#ffa500";     # Golden orange from background lights
      #   mOnTertiary = "#0a0a0a";   # Deep black

      #   # Surfaces - MORE CONTRAST between levels
      #   mSurface = "#080808";          # Much darker base (inactive workspaces)
      #   mSurfaceVariant = "#242428";   # Noticeably lighter (active workspace)

      #   # On-surface text - maintaining good contrast
      #   mOnSurface = "#e8e8e8";        # Soft white/silver (car highlights)
      #   mOnSurfaceVariant = "#a0a0a8"; # Muted gray-blue

      #   # Hover - emphasizing the warm glow
      #   mHover = "#ff5722";        # Intense orange-red
      #   mOnHover = "#ffffff";      # Pure white

      #   # Outline / shadow - deep blacks and grays
      #   mOutline = "#2a2a30";      # Dark gray from shadows
      #   mShadow = "#000000";       # Pure black
      # };
      settings = {
        # configure noctalia here; defaults will
        # be deep merged with these attributes.
        bar = {
          density = "compact";
          position = "top";
          floating = true;
          showCapsule = false;
          widgets = {
            left = [
              {
                hideUnoccupied = false;
                id = "Workspace";
                labelMode = "index";
              }
            ];
            center = [
              {
                id = "ActiveWindow";
              }
            ];
            right = [
              {
                id = "SystemMonitor";
                showLoadAverage = true;
                showNetworkStats = true;
              }
              {
                id = "WiFi";
              }
              {
                id = "Bluetooth";
              }
              {
                id = "Tray";
                drawerEnabled = false;
              }
              {
                formatHorizontal = "HH:mm ddd dd MMM";
                formatVertical = "HH mm";
                id = "Clock";
                useMonospacedFont = true;
                usePrimaryColor = true;
              }
              {
                id = "ControlCenter";
                useDistroLogo = true;
              }
            ];
          };
        };
        dock = {
          enabled = false;
        };
        general = {
          avatarImage = "/home/drfoobar/.face";
          radiusRatio = 0.2;
        };
        location = {
          monthBeforeDay = true;
          name = "Prague, Czechia";
        };
      };
    };
  };
}
