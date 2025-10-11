{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.kernelModules = [ "vboxguest" "vboxsf" "vboxvideo" ];

  users.users.exdis = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
  };

  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = with pkgs; [ libglvnd ];

  programs.fish.enable = true;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    git
    nodejs
    pyenv
    cargo
    rustc
    zig
    diff-so-fancy
    fzf
    zoxide
    eza
    ripgrep
    bat
    mesa
    foot
    kitty
    ghostty
    waybar
    wofi
    oh-my-fish
    yadm
    xclip
  ];

  nixpkgs.config.allowUnfree = true;
  virtualisation.virtualbox.guest = {
    enable = true;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];
  
  programs.firefox.enable = true;

  system.stateVersion = "25.05";
}

