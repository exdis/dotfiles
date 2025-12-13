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
    bat
    diff-so-fancy
    elixir
    erlang
    eza
    fzf
    ghostty
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
    telegram-desktop
    waybar
    wofi
    yadm
    zoxide
  ];

  programs.home-manager.enable = true;

  programs.zen-browser.enable = true;
  programs.firefox.enable = true;

  programs.quickshell.enable = true;

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
  };

  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = ~/.nixos/wp.png
    wallpaper = ,~/.nixos/wp.png
  '';

  home.stateVersion = "25.05";
}
