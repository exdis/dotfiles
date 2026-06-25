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

  # --- Fonts ------------------------------------------------------------
  # System-level font install (/Library/Fonts/Nix Fonts/), which macOS Core
  # Text discovers -- unlike the home-manager profile, which GUI apps such as
  # Ghostty don't scan. Replaces the brew font-fira-code-nerd-font cask.
  fonts.packages = [ pkgs.nerd-fonts.fira-code ];

  # --- Smoke-test marker -------------------------------------------------
  # A trivial, no-side-effect package to prove activation worked.
  environment.systemPackages = [ pkgs.nixfmt ];
}
