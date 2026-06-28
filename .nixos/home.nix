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
    weechat
    wofi
    yadm
    zoxide
  ];

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
    hyprland = {
      enable = true;
    };
    hyprpaper = {
      enable = false;
    };
    emacs = {
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
