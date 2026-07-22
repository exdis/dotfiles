{ pkgs, inputs, ... }:

{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    ./homebrew.nix
    ./defaults.nix
  ];

  # --- home-manager -----------------------------------------------------
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.users.dkolesnikov = import ../../home/darwin.nix;

  # Safety net: if HM ever finds a pre-existing file where it wants to write,
  # move it aside to <name>.before-hm instead of aborting activation.
  home-manager.backupFileExtension = "before-hm";

  # --- Platform & state ---------------------------------------------------
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  # nix-darwin state version (independent of NixOS/home-manager versions).
  system.stateVersion = 6;

  # The user nix-darwin acts on for user-scoped settings (defaults, homebrew).
  system.primaryUser = "dkolesnikov";
  users.users.dkolesnikov.home = "/Users/dkolesnikov";

  # --- Nix --------------------------------------------------------------
  # We installed upstream Nix, so let nix-darwin own /etc/nix/nix.conf.
  nix.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # --- Shell ------------------------------------------------------------
  # Register fish as a known shell. (User fish config is managed by HM in
  # home/common.nix.)
  programs.fish.enable = true;

  # --- Karabiner VirtualHIDDevice daemon --------------------------------
  # kanata emits keystrokes on macOS through the Karabiner DriverKit
  # VirtualHIDDevice. The driver extension is installed + activated (via the
  # Karabiner-VirtualHIDDevice-Manager / Karabiner-Elements.app), but its
  # userspace daemon must be running for kanata to connect. Normally
  # Karabiner-Elements.app starts it; since we don't run that at login, kanata
  # would silently stop working after a reboot (the process stays up but can't
  # grab/emit keys). Run the daemon ourselves as a root launchd daemon so it
  # always comes up at boot. kanata's KeepAlive retries until the daemon is
  # ready, so no explicit ordering is needed.
  #
  # The binary ships with the driver bundle at a fixed /Library path (root-owned,
  # updated by the Karabiner installer), so referencing it directly is stable.
  launchd.daemons.karabiner-vhidd = {
    serviceConfig = {
      Label = "dev.exdis.karabiner-vhidd";
      ProgramArguments = [
        "/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/Library/Logs/Kanata/karabiner-vhidd.out.log";
      StandardErrorPath = "/Library/Logs/Kanata/karabiner-vhidd.err.log";
    };
  };

  # --- kanata (keyboard remapper) ---------------------------------------
  # Declarative replacement for the hand-installed
  # /Library/LaunchDaemons/dev.exdis.kanata.plist.
  #
  # We deliberately keep the Homebrew kanata binary (/opt/homebrew/bin/kanata)
  # rather than pkgs.kanata: macOS keys the Input-Monitoring (TCC) grant to the
  # binary's path, and the Homebrew path is stable, whereas a /nix/store path
  # changes on every version bump and would force re-granting the permission
  # each time (silently breaking the keyboard until re-approved). The kanata
  # formula itself is managed declaratively via homebrew in Phase 3.
  #
  # The config is the HM-delivered ~/.config/kanata.kbd (see home/darwin.nix).
  # Logs match the previous setup so nothing downstream changes.
  launchd.daemons.kanata = {
    serviceConfig = {
      Label = "dev.exdis.kanata";
      ProgramArguments = [
        "/opt/homebrew/bin/kanata"
        "-c"
        "/Users/dkolesnikov/.config/kanata.kbd"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/Library/Logs/Kanata/kanata.out.log";
      StandardErrorPath = "/Library/Logs/Kanata/kanata.err.log";
    };
  };

  # --- komorebi (tiling WM, being phased out) + skhd (now a standalone app
  #     launcher) --------------------------------------------------------------
  # komorebi-for-mac (the WM) is a per-user launchd agent with RunAtLoad = false
  # / KeepAlive = false: nix-darwin registers it but it does NOT start at login;
  # you start it yourself with `komorebi-start` (and `komorebi-stop`). We run it
  # under launchd (not by hand) so its Accessibility grant is keyed to the stable
  # /opt/homebrew/bin path (same TCC-stability reason as kanata above).
  #
  # skhd is REPURPOSED: it no longer drives komorebi hotkeys -- it's now a
  # standalone global app launcher (~/.config/skhd/skhdrc: cmd+N -> focus app,
  # see home/skhd/skhdrc). The bindings shell out to yabai (below) to focus an
  # app's main window across Spaces/displays. It autostarts (RunAtLoad +
  # KeepAlive) and is fully independent of the komorebi lifecycle. Only one skhd
  # can run per user (single pid-file), so komorebi's old
  # ~/.config/komorebi/skhdrc bindings are inactive while this is in use.
  # skhd needs Accessibility granted to /opt/homebrew/bin/skhd.
  launchd.user.agents.komorebi = {
    serviceConfig = {
      Label = "dev.exdis.komorebi";
      ProgramArguments = [
        "/opt/homebrew/bin/komorebi"
        "--config"
        # Mutable "active" config (a real file, seeded/overwritten by
        # komorebi-start / komorebi-profile). Profiles are switched by copying
        # komorebi.<profile>.json onto this and RESTARTING komorebi -- live
        # `replace-configuration` deadlocks komorebi-for-mac 0.1.0.
        "/Users/dkolesnikov/.config/komorebi/komorebi.active.json"
      ];
      RunAtLoad = false;
      KeepAlive = false;
      ProcessType = "Interactive";
      EnvironmentVariables = {
        PATH = "/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };
      StandardOutPath = "/tmp/komorebi.out.log";
      StandardErrorPath = "/tmp/komorebi.err.log";
    };
  };
  launchd.user.agents.skhd = {
    serviceConfig = {
      Label = "dev.exdis.skhd";
      ProgramArguments = [
        "/opt/homebrew/bin/skhd"
        "-c"
        "/Users/dkolesnikov/.config/skhd/skhdrc"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Interactive";
      EnvironmentVariables = {
        PATH = "/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };
      StandardOutPath = "/tmp/skhd.out.log";
      StandardErrorPath = "/tmp/skhd.err.log";
    };
  };

  # yabai runs purely as a FOCUS ENGINE for skhd's cmd+N bindings (it never
  # tiles/moves windows -- ~/.config/yabai/yabairc sets layout=float and
  # manage=off). Its persistent daemon holds a proper WindowServer connection,
  # so `yabai -m window --focus <id>` reliably focuses windows on background
  # Spaces/other displays (incl. Zen's main window) -- something a short-lived
  # process spawned by skhd cannot do. Runs WITHOUT the scripting addition (no
  # SIP disable). Autostarts; needs Accessibility on /opt/homebrew/bin/yabai.
  launchd.user.agents.yabai = {
    serviceConfig = {
      Label = "dev.exdis.yabai";
      ProgramArguments = [ "/opt/homebrew/bin/yabai" ];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Interactive";
      EnvironmentVariables = {
        PATH = "/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };
      StandardOutPath = "/tmp/yabai.out.log";
      StandardErrorPath = "/tmp/yabai.err.log";
    };
  };

  # komorebi 0.1.0 ignores the static-config `animation` field on load, so we
  # disable animations at RUNTIME once komorebi is up. This agent runs ONLY
  # `komorebic` -- a socket client that talks to komorebi over a Unix socket and
  # never touches the Accessibility / event-tap / screen-recording APIs -- so it
  # does NOT require (or prompt for) any permissions. It's not the komorebi
  # binary, so it can't affect komorebi's own TCC identity. Not autostarted
  # (RunAtLoad = false); `komorebi-start` kickstarts it after komorebi is up. It
  # waits for the socket, sends "animation disable", and exits.
  launchd.user.agents.komorebi-animations = {
    serviceConfig = {
      Label = "dev.exdis.komorebi-animations";
      ProgramArguments = [
        "${pkgs.writeShellScript "komorebi-animations-off" ''
          komorebic=/opt/homebrew/bin/komorebic
          i=0
          while [ "$i" -lt 100 ]; do
            "$komorebic" state >/dev/null 2>&1 && break
            sleep 0.3; i=$((i + 1))
          done
          exec "$komorebic" animation disable
        ''}"
      ];
      RunAtLoad = false;
      KeepAlive = false;
      StandardOutPath = "/tmp/komorebi-animations.out.log";
      StandardErrorPath = "/tmp/komorebi-animations.err.log";
    };
  };

  # --- Fonts ------------------------------------------------------------
  # System-level font install (/Library/Fonts/Nix Fonts/), which macOS Core
  # Text discovers -- unlike the home-manager profile, which GUI apps such as
  # Ghostty don't scan. Replaces the brew font-fira-code-nerd-font cask.
  fonts.packages = [ pkgs.nerd-fonts.fira-code ];

  # --- Smoke-test marker -------------------------------------------------
  # A trivial, no-side-effect package to prove activation worked.
  environment.systemPackages = [ pkgs.nixfmt ];
}
