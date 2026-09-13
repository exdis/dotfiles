{ config, pkgs, inputs, ... }:

{
  # home.enableNixpkgsReleaseCheck = false;

  imports = [
    ./home/common.nix
    inputs.zen-browser.homeModules.beta
    ./modules/librewolf.nix
  ];

  home.username = "exdis";
  home.homeDirectory = "/home/exdis";

  home.packages = with pkgs; [
    android-studio
    azure-cli
    azure-functions-core-tools
    bat
    diff-so-fancy
    beamPackages.elixir
    beamPackages.erlang
    eza
    fd
    filezilla
    fzf
    ghostty
    github-copilot-cli
    gradle
    # hyprpaper  # replaced by noctalia's built-in wallpaper management
    jdk21
    nautilus
    fastfetch
    neovim
    nodejs
    p7zip
    beamPackages.rebar3
    ripgrep
    rofi
    streamcontroller
    telegram-desktop
    waybar
    wofi
    yadm
    zoxide
  ] ++ [
    # pyroclear -- animated `clear` (Rust, github:shreyanth-sureshkrishnaa/pyroclear).
    # Built from the flake input; not in nixpkgs. Kept here rather than in
    # home/common.nix because upstream is Linux-only (its flake has no darwin
    # system and meta.platforms = lib.platforms.linux), so the Mac must not see
    # it. Exposed as the `cls` alias below -- `clear` stays coreutils.
    inputs.pyroclear.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Linux-only alias; the shared aliases live in home/common.nix, which the
  # darwin host also imports and where `pyroclear` would not resolve.
  programs.fish.shellAliases.cls = "pyroclear";

  # NOTE: the uwsm autostart that used to live here
  # (programs.fish.loginShellInit -> `uwsm check may-start && exec uwsm start
  # hyprland.desktop`) was removed when the greeter went in. greetd owns tty1
  # (terminal.vt = 1, autovt@tty1 disabled, Conflicts=getty@tty1), so there is
  # no console login left on VT 1 and `uwsm check may-start` -- which only
  # passes on VT 1 -- could never succeed again. The session is now started by
  # the "Hyprland (uwsm-managed)" entry picked in ReGreet; see
  # services.displayManager.regreet in configuration.nix.

  # uwsm sources this into the systemd user manager and the D-Bus activation
  # environment, which is what portals and dbus-activated services read. The
  # `env = ` lines in ~/.config/hypr/hyprland.conf only reach processes Hyprland
  # spawns itself, so these are mirrored here rather than moved.
  #
  # Still required now that the session is started from the greeter rather than
  # from a login shell: the "Hyprland (uwsm-managed)" entry also goes through
  # `uwsm start`, so the same env preloader applies.
  xdg.configFile."uwsm/env".text = ''
    export XCURSOR_SIZE=24
    export HYPRCURSOR_SIZE=24
    export GDK_SCALE=1
    export GDK_DPI_SCALE=1
    export QT_AUTO_SCREEN_SCALE_FACTOR=1
    export QT_SCALE_FACTOR=1
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
  '';

  programs.home-manager.enable = true;

  programs.zen-browser.enable = true;
  programs.firefox.enable = true;
  # Adopt the new XDG default profile location (~/.config/mozilla/firefox).
  # NOTE: the existing profile data was moved from ~/.mozilla/firefox manually;
  # HM regenerates profiles.ini at the new path automatically.
  programs.firefox.configPath = "${config.xdg.configHome}/mozilla/firefox";

  programs.quickshell.enable = true;

  programs.opencode = {
    enable = true;
    settings = builtins.fromJSON (builtins.readFile ./opencode-config.json);
  };

  # programs.neovim = {
  #   enable = true;
  #   defaultEditor = true;
  # };

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: [
      epkgs.treesit-grammars.with-all-grammars
    ];
  };

  services.emacs = {
    enable = true;
    defaultEditor = true;
  };

  stylix.targets = {
    zen-browser = {
      enable = true;
      profileNames = [ "default" ];
    };
    firefox = {
      enable = true;
      profileNames = [ "default" ];
    };
    librewolf = {
      enable = true;
      profileNames = [ "default" ];
    };
    hyprpaper = {
      enable = false;
    };
    emacs = {
      enable = false;
    };
    # Stylix gained a noctalia target which forces
    # programs.noctalia.settings.theme.custom_palette = "stylix", conflicting
    # with the hand-written "alabaster" palette in modules/noctalia.nix.
    noctalia = {
      enable = false;
    };
  };

  # Wallpaper is now handled by noctalia (see modules/noctalia.nix), which
  # conflicts with hyprpaper. Keeping this disabled to avoid two daemons
  # fighting over the background.
  # xdg.configFile."hypr/hyprpaper.conf".text = ''
  #   preload = ~/.nixos/uwp1.jpeg
  #   wallpaper = ,~/.nixos/uwp1.jpeg
  # '';

  home.stateVersion = "25.05";
}
