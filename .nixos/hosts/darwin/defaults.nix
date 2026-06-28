{ ... }:

# Declarative macOS preferences (Phase 5).
#
# These mirror the settings that were customised by hand on this machine
# (discovered via `defaults read`), so the system stays identical while the
# values become reproducible. Settings already at the macOS default are
# intentionally omitted to keep this list meaningful.
#
# nix-darwin applies most of these by running `defaults write` on activation
# and restarting the affected apps (Dock/Finder). A few (notably
# spaces.spans-displays) only take full effect after logout/restart.
{
  system.defaults = {
    # --- Global / NSGlobalDomain --------------------------------------
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark"; # system-wide dark mode
    };

    # --- Dock ----------------------------------------------------------
    dock = {
      autohide = true;
      tilesize = 42;
      magnification = true;
      largesize = 60;
      show-recents = false; # no recent apps in the Dock
      mru-spaces = false; # don't auto-rearrange Spaces by use (needed for AeroSpace)
      wvous-br-corner = 14; # bottom-right hot corner = Quick Note
    };

    # --- Finder --------------------------------------------------------
    finder = {
      FXPreferredViewStyle = "Nlsv"; # list view by default
    };

    # --- Trackpad ------------------------------------------------------
    trackpad = {
      Clicking = true; # tap to click
      TrackpadThreeFingerDrag = true;
      FirstClickThreshold = 1; # light click pressure
      SecondClickThreshold = 1;
    };

    # --- Spaces --------------------------------------------------------
    # "Displays have separate Spaces" is OFF -> one Space spans all displays.
    # Takes effect after logout.
    spaces.spans-displays = true;
  };
}
