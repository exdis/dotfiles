{ lib, pkgs, config, inputs, ... }:

# macOS-specific home-manager configuration. Imports the shared cross-platform
# module and adds anything that only applies to the Mac.
let
  # Non-official Homebrew taps that must be trusted (keep in sync with the
  # `taps` in hosts/darwin/homebrew.nix).
  trustedTaps = [
    "azure/functions"
    "koekeishiya/formulae"
    "lgug2z/tap"
    "nikitabobko/tap"
    "oven-sh/bun"
    "powershell/tap"
    "universal-ctags/universal-ctags"
  ];
  homebrewTrustFile = pkgs.writeText "homebrew-trust.json"
    (builtins.toJSON { trustedtaps = trustedTaps; });

  # --- komorebi config profiles -----------------------------------------
  # komorebi ties each workspace to a monitor by its POSITION in `monitors`,
  # so a different physical setup (1 external at home vs 2 at the office) needs
  # a different workspace->monitor distribution. We can't express both in one
  # static file, so we generate two profiles that share everything except the
  # `monitors` array, and switch between them at runtime with the
  # `komorebi-profile` script (via `komorebic replace-configuration`).
  #
  # Keybindings don't care which profile is active: skhdrc uses
  # `focus-named-workspace <name>` / `move-to-named-workspace <name>`, which
  # resolve a workspace by NAME wherever it currently lives.
  komorebiBase = {
    "$schema" = "https://komorebi-for-mac.lgug2z.com/komorebi.0.1.0.schema.json";
    app_specific_configuration_path = "$HOME/.config/komorebi/applications.json";
    cross_monitor_move_behaviour = "Insert";
    floating_window_aspect_ratio = "Widescreen";
    floating_layer_behaviour = "Float";
    resize_delta = 100;
    # komorebi warps the cursor to the focused window's center on EVERY focus
    # change -- including the focus macOS sends when you click a window, which
    # yanks the pointer away from where you clicked. It's a single global flag
    # (no way to separate click-focus from keyboard-focus), so we turn it off.
    # Trade-off: no more auto-centering on workspace switch either.
    mouse_follows_focus = false;
    default_workspace_padding = 8;
    default_container_padding = 8;
    border = true;
    border_width = 3;
    border_offset = 0;
    # Snappy, no motion: disable animations. NOTE: the installed komorebi 0.1.0
    # ignores this static-config field on load (that wiring came after 0.1.0),
    # so the actual disabling is done at runtime by the separate, komorebic-only
    # `komorebi-animations` launchd agent (hosts/darwin/default.nix). We still
    # set it here so it Just Works once komorebi is upgraded past 0.1.0.
    animation = {
      enabled = false;
    };
    ignore_rules = [ ];
    floating_applications = [ ];
    manage_rules = [ ];
  };
  komorebiWs = name: { inherit name; layout = "BSP"; };
  # Main laptop panel always holds 1-6 and 10 (monitor index 0).
  komorebiMain = { workspaces = map komorebiWs [ "1" "2" "3" "4" "5" "6" "10" ]; };
  # Home: a single external monitor holds 7, 8 and 9.
  komorebiHome = komorebiBase // {
    monitors = [
      komorebiMain
      { workspaces = map komorebiWs [ "7" "8" "9" ]; }
    ];
  };
  # Office: two externals -- 7 on the first, 8 & 9 on the second.
  komorebiOffice = komorebiBase // {
    monitors = [
      komorebiMain
      { workspaces = map komorebiWs [ "7" ]; }
      { workspaces = map komorebiWs [ "8" "9" ]; }
    ];
  };
  # Switch the live config (komorebi must already be running -- that's a
  # requirement of `replace-configuration`). `auto` picks a profile from the
  # number of connected displays: 3+ (laptop + 2 externals) => office, else home.
  komorebiProfileScript = pkgs.writeShellScriptBin "komorebi-profile" ''
    set -eu
    komorebic=/opt/homebrew/bin/komorebic
    cfgdir="$HOME/.config/komorebi"
    profile="''${1:-auto}"
    if [ "$profile" = "auto" ]; then
      count="$("$komorebic" monitor-information | ${pkgs.jq}/bin/jq 'length')"
      if [ "$count" -ge 3 ]; then profile=office; else profile=home; fi
      echo "komorebi-profile: $count displays -> $profile" >&2
    fi
    case "$profile" in
      home|office)
        "$komorebic" replace-configuration "$cfgdir/komorebi.$profile.json"
        # replace-configuration reloads the layout but doesn't always re-fit
        # already-managed windows, which can leave a tile oversized/overflowing
        # the screen until the next manual retile -- so force one now.
        sleep 1
        exec "$komorebic" retile
        ;;
      *) echo "usage: komorebi-profile [home|office|auto]" >&2; exit 1 ;;
    esac
  '';
  # komorebi + skhd are launchd user agents (declared in hosts/darwin/default.nix)
  # with RunAtLoad = false / KeepAlive = false, so they do NOT autostart -- these
  # wrappers start/stop them on demand. `komorebi-start` makes sure each agent is
  # loaded (bootstrap) and then launches it (kickstart), komorebi first so its
  # socket is up before skhd and the one-shot animations agent run.
  # `komorebi-stop` boots them out. The plist filenames match each agent's Label.
  komorebiStartScript = pkgs.writeShellScriptBin "komorebi-start" ''
    set -u
    uid="$(id -u)"
    agents="$HOME/Library/LaunchAgents"
    start() {
      # ensure the agent is loaded (no-op/‘already bootstrapped’ errors ignored),
      # then start it (kickstart works whether or not RunAtLoad is set).
      launchctl bootstrap "gui/$uid" "$agents/$1.plist" 2>/dev/null || true
      launchctl kickstart "gui/$uid/$1" 2>/dev/null || true
    }
    start dev.exdis.komorebi
    sleep 1
    start dev.exdis.skhd
    start dev.exdis.komorebi-animations
    echo "komorebi + skhd + animations-off (launchd agents) started."
  '';
  komorebiStopScript = pkgs.writeShellScriptBin "komorebi-stop" ''
    set -u
    uid="$(id -u)"
    # Bootout skhd first so the keyboard is freed, then komorebi (SIGTERM makes
    # komorebi restore all managed windows on the way out).
    launchctl bootout "gui/$uid/dev.exdis.skhd" 2>/dev/null || true
    launchctl bootout "gui/$uid/dev.exdis.komorebi-animations" 2>/dev/null || true
    launchctl bootout "gui/$uid/dev.exdis.komorebi" 2>/dev/null || true
    echo "komorebi + skhd (launchd agents) stopped. AeroSpace can take over now."
  '';
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

  # --- komorebi (tiling WM, trialling alongside AeroSpace) --------------
  # komorebi-for-mac (brew: lgug2z/tap/komorebi-for-mac) + skhd hotkey daemon
  # (brew: koekeishiya/formulae/skhd). Files under ~/.config/komorebi, all
  # read-only /nix/store copies (komorebi never writes back to its static
  # config; skhd never writes its rc):
  #   * komorebi.json        -- ACTIVE config read on `komorebic start`.
  #                             Defaults to the home profile.
  #   * komorebi.home.json   -- 1 external: workspaces 7/8/9 all on it.
  #   * komorebi.office.json -- 2 externals: 7 on the first, 8/9 on the second.
  #   * applications.json    -- app-specific float rules for dialogs/updaters,
  #                             referenced by app_specific_configuration_path.
  #   * skhdrc               -- cmd-based keybindings mirroring aerospace.toml;
  #                             workspace keys use NAMED workspaces so the same
  #                             bindings work under either profile.
  # Switch profile at runtime (komorebi must be running):
  #   komorebi-profile home | komorebi-profile office | komorebi-profile auto
  #
  # komorebi + skhd are launchd user agents (hosts/darwin/default.nix) but are
  # MANUAL-START (RunAtLoad = false, KeepAlive = false): nothing starts at login.
  # Bring komorebi up with `komorebi-start` and down with `komorebi-stop`; while
  # it's down the keyboard is free for AeroSpace (still fully configured as a
  # fallback). Profiles switch at runtime with `komorebi-profile home|office|
  # auto` (komorebi.json's default is the home profile, read at agent start).
  #
  # PERMISSIONS (one-time). Because launchd starts these binaries directly, macOS
  # attributes the grants to the binaries themselves (stable, unlike a terminal-
  # launched process). Grant in System Settings > Privacy & Security:
  #   Accessibility     -> add /opt/homebrew/bin/komorebi AND /opt/homebrew/bin/skhd
  #   Screen Recording  -> add /opt/homebrew/bin/komorebi   (to read window titles)
  # In the "+" file picker use Cmd+Shift+G and paste the path (they're CLI tools,
  # not .app bundles). Until granted, komorebi/skhd exit on start; check
  # /tmp/komorebi.err.log and /tmp/skhd.err.log. NB: the grant is keyed to the
  # resolved Cellar path, so a komorebi/skhd version bump may require re-granting.
  xdg.configFile."komorebi/komorebi.json".text = builtins.toJSON komorebiHome;
  xdg.configFile."komorebi/komorebi.home.json".text = builtins.toJSON komorebiHome;
  xdg.configFile."komorebi/komorebi.office.json".text = builtins.toJSON komorebiOffice;
  xdg.configFile."komorebi/applications.json".source = ./komorebi/applications.json;
  xdg.configFile."komorebi/skhdrc".source = ./komorebi/skhdrc;

  # --- herdr (experimental tmux alternative) ----------------------------
  # "agent multiplexer" (Rust) from github:ogulcancelik/herdr, built from the
  # flake input. Config ported from the tmux setup (see home/herdr/config.toml).
  # Delivered read-only from the store; herdr would normally write settings back
  # here, so in-app Settings changes won't persist -- edit the source + rebuild.
  home.packages = [
    inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
    komorebiProfileScript
    komorebiStartScript
    komorebiStopScript
  ];
  xdg.configFile."herdr/config.toml".source = ./herdr/config.toml;
  # Seamless vim/herdr Ctrl+h/j/k/l navigation: the herdr side of
  # paulbkim-dev/vim-herdr-navigation (a plain, non-flake repo input). Bound via
  # [[keys.command]] in herdr/config.toml; the nvim side is in
  # home/nvim/lua/main-config.lua. Needs jq (in homebrew.nix brews).
  xdg.configFile."herdr/navigate.sh".source = "${inputs.vim-herdr-navigation}/navigate.sh";

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
