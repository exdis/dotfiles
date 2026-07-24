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
    # Windows komorebi should never manage (left floating where they appear).
    # Browserosaurus is a transient browser-picker popup, not a real window.
    ignore_rules = [
      { kind = "Exe"; id = "Browserosaurus"; matching_strategy = "Equals"; }
    ];
    floating_applications = [ ];
    manage_rules = [ ];
  };
  # Workspace name -> apps bound to it (matched on komorebi's `exe` = macOS
  # window-owner name). These become per-workspace initial_workspace_rules.
  komorebiWsAppRules = {
    "3" = [ "Microsoft Teams" ];
    "4" = [ "Telegram" ];
    "8" = [ "Zen" ];
    "9" = [ "Edge" ];
  };
  # Flat list of every explicitly-bound exe, used to EXCLUDE them from the
  # workspace-1 catch-all below.
  komorebiBoundExes = lib.concatLists (lib.attrValues komorebiWsAppRules);
  komorebiWs = name:
    let
      # Simple "this app -> here" rules for the bound workspaces.
      appRules = map (id: { kind = "Exe"; inherit id; matching_strategy = "Equals"; })
        (komorebiWsAppRules.${name} or [ ]);
      # Workspace 1 is the catch-all: one COMPOSITE rule (all conditions must
      # hold) = "exe matches .*" AND "exe is not any of the bound apps". Because
      # it excludes the bound apps, it can't steal them from their own rules
      # despite komorebi's first-match-by-config-order precedence.
      catchAll = lib.optionals (name == "1") [
        ([ { kind = "Exe"; id = ".*"; matching_strategy = "Regex"; } ]
          ++ map (id: { kind = "Exe"; inherit id; matching_strategy = "DoesNotEqual"; })
            komorebiBoundExes)
      ];
      # initial_workspace_rules = routed here on first open, still movable after
      # (workspace_rules would instead forcibly pin them on every event).
      rules = appRules ++ catchAll;
    in
    { inherit name; layout = "BSP"; }
    // lib.optionalAttrs (rules != [ ]) { initial_workspace_rules = rules; };
  # Main laptop panel always holds 1-6 and 10 (monitor index 0).
  komorebiMain = { workspaces = map komorebiWs [ "1" "2" "3" "4" "5" "6" "10" ]; };
  # Solo: laptop only, ALL workspaces 1-10 on it (0 external monitors).
  komorebiSolo = komorebiBase // {
    monitors = [
      { workspaces = map komorebiWs [ "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" ]; }
    ];
  };
  # Home: a single external monitor holds 7, 8 and 9.
  komorebiHome = komorebiBase // {
    monitors = [
      komorebiMain
      { workspaces = map komorebiWs [ "7" "8" "9" ]; }
    ];
  };
  # Office: two externals. Physical layout is portrait (left) | landscape
  # (right) with the laptop below the landscape. komorebi's index<->panel order
  # isn't stable across replug, so pin each slot by serial_number_id:
  #   0 = laptop, 1 = DELL landscape, 2 = DELL portrait.
  # window_hiding_position matters here: komorebi stashes hidden windows just off
  # a monitor's edge, and the default (BottomLeft) pushes the LANDSCAPE monitor's
  # hidden windows left -- straight onto the portrait. So hide toward each
  # monitor's EMPTY side: landscape+laptop -> BottomRight, portrait -> BottomLeft.
  komorebiOffice = komorebiBase // {
    display_index_preferences = {
      "0" = "4251086178"; # Built-in Retina (laptop)
      "1" = "842545484"; # DELL U3223QE landscape
      "2" = "842479692"; # DELL U3223QE portrait
    };
    monitors = [
      (komorebiMain // { window_hiding_position = "BottomRight"; })
      { workspaces = map komorebiWs [ "8" "9" ]; window_hiding_position = "BottomRight"; }
      { workspaces = map komorebiWs [ "7" ]; window_hiding_position = "BottomLeft"; }
    ];
  };
  # Switch profile by RESTARTING komorebi with the chosen config. We do NOT use
  # `komorebic replace-configuration`: live config reload deadlocks
  # komorebi-for-mac 0.1.0 (process stays up but focus/border/event handling
  # freezes). Instead we copy komorebi.<profile>.json onto the mutable
  # komorebi.active.json that the launchd agent reads, then hard-restart the
  # agent (kickstart -k). `auto` picks from the connected-monitor count (komorebi
  # counts laptop + externals): 1 => solo (all on laptop), 2 => home (7/8/9 on
  # the one external), 3+ => office (7 on one external, 8/9 on the other).
  # Idempotent: if the target profile is already active, it does nothing (so it's
  # safe to call repeatedly / from a monitor-change hook without needless
  # restarts that would scramble your layout).
  komorebiProfileScript = pkgs.writeShellScriptBin "komorebi-profile" ''
    set -eu
    uid="$(id -u)"
    komorebic=/opt/homebrew/bin/komorebic
    cfgdir="$HOME/.config/komorebi"
    profile="''${1:-auto}"
    if [ "$profile" = "auto" ]; then
      count="$("$komorebic" monitor-information 2>/dev/null | ${pkgs.jq}/bin/jq 'length' 2>/dev/null || echo 1)"
      case "$count" in
        1) profile=solo ;;
        2) profile=home ;;
        *) profile=office ;;
      esac
      echo "komorebi-profile: $count monitors -> $profile" >&2
    fi
    case "$profile" in
      solo|home|office) ;;
      *) echo "usage: komorebi-profile [solo|home|office|auto]" >&2; exit 1 ;;
    esac
    target="$cfgdir/komorebi.$profile.json"
    # Idempotent: already on this profile -> nothing to do (avoids a needless
    # komorebi restart that would re-tile everything).
    if [ -f "$cfgdir/komorebi.active.json" ] && cmp -s "$target" "$cfgdir/komorebi.active.json"; then
      echo "komorebi already on the $profile profile; no restart."
      exit 0
    fi
    cp -f "$target" "$cfgdir/komorebi.active.json"
    # Hard-restart komorebi so it loads the new config from scratch (no live
    # reload). skhd keeps running; re-run the one-shot animations agent after.
    launchctl kickstart -k "gui/$uid/dev.exdis.komorebi"
    launchctl kickstart "gui/$uid/dev.exdis.komorebi-animations" 2>/dev/null || true
    echo "komorebi restarted with the $profile profile."
  '';
  # komorebi + skhd are launchd user agents (declared in hosts/darwin/default.nix)
  # with RunAtLoad = false / KeepAlive = false, so they do NOT autostart -- these
  # wrappers start/stop them on demand. `komorebi-start` seeds the mutable active
  # config (if missing), makes sure each agent is loaded (bootstrap) and then
  # launches it (kickstart), komorebi first so its socket is up before skhd and
  # the one-shot animations agent run. `komorebi-stop` boots them out.
  komorebiStartScript = pkgs.writeShellScriptBin "komorebi-start" ''
    set -u
    uid="$(id -u)"
    agents="$HOME/Library/LaunchAgents"
    cfgdir="$HOME/.config/komorebi"
    # Seed the mutable active config with the RIGHT profile for the currently
    # connected monitors, before komorebi starts. komorebi isn't up yet, so we
    # can't ask komorebic -- count displays via system_profiler instead (each
    # display prints one "Resolution:" line). 1 => solo, 2 => home, 3+ => office.
    count="$(/usr/sbin/system_profiler SPDisplaysDataType 2>/dev/null | grep -c 'Resolution:')"
    [ "$count" -ge 1 ] || count=1
    case "$count" in
      1) seed=solo ;;
      2) seed=home ;;
      *) seed=office ;;
    esac
    cp -f "$cfgdir/komorebi.$seed.json" "$cfgdir/komorebi.active.json"
    echo "komorebi-start: $count monitors -> $seed profile" >&2
    start() {
      # ensure the agent is loaded (no-op/‘already bootstrapped’ errors ignored),
      # then start it (kickstart works whether or not RunAtLoad is set).
      launchctl bootstrap "gui/$uid" "$agents/$1.plist" 2>/dev/null || true
      launchctl kickstart "gui/$uid/$1" 2>/dev/null || true
    }
    start dev.exdis.komorebi
    sleep 1
    start dev.exdis.komorebi-animations
    echo "komorebi + animations-off (launchd agents) started."
  '';
  komorebiStopScript = pkgs.writeShellScriptBin "komorebi-stop" ''
    set -u
    uid="$(id -u)"
    # skhd is now an independent app launcher, so komorebi-stop leaves it alone.
    launchctl bootout "gui/$uid/dev.exdis.komorebi-animations" 2>/dev/null || true
    launchctl bootout "gui/$uid/dev.exdis.komorebi" 2>/dev/null || true
    echo "komorebi (launchd agent) stopped."
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
  #   * komorebi.home.json   -- 1 external: workspaces 7/8/9 all on it.
  #   * komorebi.office.json -- 2 externals: 7 on the first, 8/9 on the second.
  #     (komorebi.active.json is a RUNTIME copy of one of these, written by
  #      komorebi-start/komorebi-profile; it's what the komorebi agent reads.)
  #   * applications.json    -- app-specific float rules for dialogs/updaters,
  #                             referenced by app_specific_configuration_path.
  #   * skhdrc               -- cmd-based keybindings mirroring aerospace.toml;
  #                             workspace keys use NAMED workspaces so the same
  #                             bindings work under either profile.
  # Switch profile (RESTARTS komorebi -- no live reload, which deadlocks it):
  #   komorebi-profile home | komorebi-profile office | komorebi-profile auto
  #
  # komorebi + skhd are launchd user agents (hosts/darwin/default.nix) but are
  # MANUAL-START (RunAtLoad = false, KeepAlive = false): nothing starts at login.
  # Bring komorebi up with `komorebi-start` and down with `komorebi-stop`; while
  # it's down the keyboard is free for AeroSpace (still fully configured as a
  # fallback). Profiles switch by restarting komorebi with `komorebi-profile
  # home|office|auto` (default profile is home, via komorebi.active.json).
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
  xdg.configFile."komorebi/komorebi.solo.json".text = builtins.toJSON komorebiSolo;
  xdg.configFile."komorebi/komorebi.home.json".text = builtins.toJSON komorebiHome;
  xdg.configFile."komorebi/komorebi.office.json".text = builtins.toJSON komorebiOffice;
  xdg.configFile."komorebi/applications.json".source = ./komorebi/applications.json;
  xdg.configFile."komorebi/skhdrc".source = ./komorebi/skhdrc;

  # --- skhd app launcher + yabai focus engine ---------------------------
  # skhd is a standalone global app launcher (cmd+N -> focus app), decoupled
  # from komorebi. Its launchd agent (dev.exdis.skhd, hosts/darwin/default.nix)
  # autostarts it and needs Accessibility on /opt/homebrew/bin/skhd. The cmd+N
  # bindings shell out to the yabai-focus helpers below, which ask the yabai
  # daemon (dev.exdis.yabai) to focus an app's main window across Spaces/
  # displays. komorebi's own skhdrc is inactive while this runs (one skhd/user).
  xdg.configFile."skhd/skhdrc".source = ./skhd/skhdrc;
  xdg.configFile."skhd/yabai-focus.sh".source = ./skhd/yabai-focus.sh;
  xdg.configFile."skhd/yabai-focus-ghostty.sh".source = ./skhd/yabai-focus-ghostty.sh;
  xdg.configFile."skhd/yabai-focus-ghostty-external.sh".source = ./skhd/yabai-focus-ghostty-external.sh;

  # yabai reads this on start (layout=float, manage=off) so it acts purely as a
  # focus engine and never tiles/moves windows. yabai looks for it at
  # ~/.config/yabai/yabairc; it must be executable (yabai execs it).
  xdg.configFile."yabai/yabairc" = {
    source = ./yabai/yabairc;
    executable = true;
  };

  # Neither skhd nor yabai watch their configs, and their launchd plists don't
  # change when only the (store-symlinked) config changes, so a `darwin-rebuild
  # switch` alone leaves them running the OLD config. skhd reloads on SIGUSR1;
  # yabai reloads by restarting its launchd service (it's nix-managed as
  # dev.exdis.yabai, NOT via `yabai --start-service`, so kickstart the agent
  # rather than `yabai --restart-service`). `|| true` so activation never fails
  # if they aren't running yet.
  home.activation.reloadSkhd = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    /usr/bin/killall -USR1 skhd 2>/dev/null || true
    /bin/launchctl kickstart -k "gui/$(/usr/bin/id -u)/dev.exdis.yabai" 2>/dev/null || true
  '';

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
