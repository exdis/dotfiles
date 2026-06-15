{ ... }:

# macOS-specific home-manager configuration. Imports the shared cross-platform
# module and adds anything that only applies to the Mac.
{
  imports = [ ./common.nix ];

  home.username = "dkolesnikov";
  home.homeDirectory = "/Users/dkolesnikov";

  home.stateVersion = "25.05";

  # --- kanata config ----------------------------------------------------
  # ~/.config/kanata.kbd (home-row mods + Cyrillic deflocalkeys). macOS-only
  # here because the config uses deflocalkeys-macos / macos-dev-names-exclude;
  # a Linux host would ship its own .kbd. Static (kanata never writes back), so
  # delivered as a read-only /nix/store copy. The launchd daemon that runs
  # kanata against this path is declared in hosts/darwin/default.nix.
  xdg.configFile."kanata.kbd".source = ./kanata/kanata.kbd;

  # --- AeroSpace (tiling window manager) --------------------------------
  # ~/.config/aerospace/aerospace.toml. Self-contained (no external scripts),
  # static (AeroSpace never writes it back), so delivered as a read-only
  # /nix/store copy. Edit the source then rebuild + reload-config in AeroSpace
  # (alt-shift-semicolon -> esc). The AeroSpace cask is declared via homebrew
  # in Phase 3; obsolete neighbours (yabai, sketchybar, phoenix, skhd) are left
  # unmanaged and retired at the Phase 6 cutover.
  xdg.configFile."aerospace/aerospace.toml".source = ./aerospace/aerospace.toml;

  # --- Homebrew tap trust -----------------------------------------------
  # Homebrew 6.0 enforces HOMEBREW_REQUIRE_TAP_TRUST by default: it refuses to
  # load formulae/casks from non-official taps unless they're trusted with
  # `brew trust`, which otherwise halts `brew bundle` during activation. We
  # declare the trust list rather than running `brew trust` imperatively.
  # XDG_CONFIG_HOME is unset on this machine, so Homebrew reads ~/.homebrew/
  # trust.json (it would use $XDG_CONFIG_HOME/homebrew/trust.json otherwise).
  # Keep this list in sync with the non-official `taps` in
  # hosts/darwin/homebrew.nix.
  #
  # NOTE: nix-darwin runs `brew bundle` BEFORE home-manager activation, so this
  # file is written one generation "behind" -- it's read from the previous
  # generation's symlink, which is fine steady-state. A brand-new machine needs
  # a one-time `brew trust --tap <name>` for each tap below before the first
  # successful activation.
  home.file.".homebrew/trust.json".text = builtins.toJSON {
    trustedtaps = [
      "azure/functions"
      "nikitabobko/tap"
      "oven-sh/bun"
      "powershell/tap"
      "universal-ctags/universal-ctags"
      "wez/wezterm"
    ];
  };
}
