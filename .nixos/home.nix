{ config, pkgs, inputs, ... }:

{
  # home.enableNixpkgsReleaseCheck = false;

  imports = [
    inputs.zen-browser.homeModules.beta
    ./modules/librewolf.nix
  ];

  home.username = "exdis";
  home.homeDirectory = "/home/exdis";

  home.packages = with pkgs; [
    azure-cli
    azure-functions-core-tools
    bat
    diff-so-fancy
    elixir
    erlang
    eza
    filezilla
    fzf
    ghostty
    github-copilot-cli
    hyprpaper
    nautilus
    neofetch
    neovim
    nodejs
    oh-my-fish
    p7zip
    rebar3
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
  programs.zen-browser.suppressXdgMigrationWarning = true;
  programs.firefox.enable = true;

  programs.quickshell.enable = true;

  programs.opencode = {
    enable = true;
    settings = builtins.fromJSON (builtins.readFile ./opencode-config.json);
  };

  # programs.neovim = {
  #   enable = true;
  #   defaultEditor = true;
  # };

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
  };

  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = ~/.nixos/uwp1.jpeg
    wallpaper = ,~/.nixos/uwp1.jpeg
  '';

  home.stateVersion = "25.05";
}
