{ config, pkgs, inputs, ... }:

{
  # home.enableNixpkgsReleaseCheck = false;

  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  home.username = "exdis";
  home.homeDirectory = "/home/exdis";

  home.packages = with pkgs; [
    bat
    diff-so-fancy
    eza
    fzf
    ghostty
    hyprpaper
    librewolf
    nautilus
    neofetch
    neovim
    nodejs
    oh-my-fish
    p7zip
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
    hyprland = {
      enable = true;
    };
  };

  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = ~/.nixos/wp.jpg
    wallpaper = ,~/.nixos/wp.jpg
  '';

  home.stateVersion = "25.05";
}
