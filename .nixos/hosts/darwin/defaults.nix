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

      # Kill macOS's own window open/close/move/resize animation. komorebi moves
      # and hides (off-screen) windows via the Accessibility API, and macOS
      # animates those position/size changes -- that's the sliding you still see
      # on workspace switches even with komorebi's own animations disabled.
      NSAutomaticWindowAnimationsEnabled = false;
      # Near-instant window resize (default ~0.2s). 0.001 = effectively no
      # animation for AX-driven resizes/moves. Standard yabai/komorebi tweak.
      NSWindowResizeTime = 0.001;
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
    # "Displays have separate Spaces" is ON -> each display has its own Spaces
    # (macOS default). Was previously OFF (spans-displays = true) for the
    # komorebi/AeroSpace tiling setup; restored to ON now that window management
    # is moving to Raycast. Takes effect after logout.
    spaces.spans-displays = false;
  };
}
