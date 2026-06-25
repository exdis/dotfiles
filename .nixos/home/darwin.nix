{ lib, pkgs, config, ... }:

# macOS-specific home-manager configuration. Imports the shared cross-platform
# module and adds anything that only applies to the Mac.
let
  # Non-official Homebrew taps that must be trusted (keep in sync with the
  # `taps` in hosts/darwin/homebrew.nix).
  trustedTaps = [
    "azure/functions"
    "nikitabobko/tap"
    "oven-sh/bun"
    "powershell/tap"
    "universal-ctags/universal-ctags"
  ];
  homebrewTrustFile = pkgs.writeText "homebrew-trust.json"
    (builtins.toJSON { trustedtaps = trustedTaps; });
in
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
  # `brew trust`, which otherwise halts `brew bundle` during activation.
  #
  # Homebrew requires the trust store to be a REAL file in a user-owned,
  # writable directory: a read-only /nix/store symlink (what home.file would
  # create) is rejected with "Refusing to write insecure trust store". So we
  # materialise a real file via an activation script instead. XDG_CONFIG_HOME is
  # unset on this machine, so Homebrew reads ~/.homebrew/trust.json (it would use
  # $XDG_CONFIG_HOME/homebrew/trust.json otherwise).
  #
  # NOTE: nix-darwin runs `brew bundle` BEFORE home-manager activation, so this
  # file is refreshed one generation "behind" -- brew reads the file written by
  # the previous activation, which is fine steady-state. A brand-new machine
  # needs a one-time `brew trust --tap <name>` (or this file written by hand)
  # before the first successful activation.
  home.activation.homebrewTrust = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "${config.home.homeDirectory}/.homebrew"
    run rm -f "${config.home.homeDirectory}/.homebrew/trust.json"
    run ${pkgs.coreutils}/bin/install -m 0644 ${homebrewTrustFile} \
      "${config.home.homeDirectory}/.homebrew/trust.json"
  '';
}
