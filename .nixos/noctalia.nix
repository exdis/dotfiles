{ pkgs, inputs, ... }:
{
  home-manager.users.exdis = {
    # import the home manager module
    imports = [
      inputs.noctalia.homeModules.default
    ];

    # configure options
    programs.noctalia-shell = {
      enable = true;
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
        mHover = "#1c1f22";        # base02
        mOnHover = "#ffffff";     # base07

        # Outline / shadow
        mOutline = "#5b6268";     # base03
        mShadow = "#000000";
      };
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
        colorSchemes.predefinedScheme = "Monochrome";
        general = {
          avatarImage = "/home/drfoobar/.face";
          radiusRatio = 0.2;
        };
        location = {
          monthBeforeDay = true;
          name = "Marseille, France";
        };
      };
      # this may also be a string or a path to a JSON file,
      # but in this case must include *all* settings.
    };
  };
}
