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
      colors = {
        mPrimary = "#61afef";
        mOnPrimary = "#0b0c0d";
        mSecondary = "#56b6c2";
        mOnSecondary = "#0b0c0d";
        mTertiary = "#98c379";
        mOnTertiary = "#0b0c0d";
        mError = "#e06c75";
        mOnError = "#0b0c0d";
        mSurface = "#1c1f22";
        mOnSurface = "#e6eef3";
        mSurfaceVariant = "#101214";
        mOnSurfaceVariant = "#8b9499";
        mOutline = "#5b6268";
        mShadow = "#0b0c0d";
        mHover = "#c678dd";
        mOnHover = "#0b0c0d";
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
          name = "Marseille, France";
        };
      };
      # this may also be a string or a path to a JSON file,
      # but in this case must include *all* settings.
    };
  };
}
