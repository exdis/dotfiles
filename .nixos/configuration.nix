{ config, lib, pkgs, inputs, ... }: let
  kanata = import ./modules/kanata.nix;
in
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.kernelModules = [ "uinput" ];

  hardware.uinput.enable = true;

  users.groups.uinput = { };

  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
  '';

  users.users.exdis = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ libglvnd ];
  };

  services.xserver = {
    videoDrivers = [ "nvidia" ];
    xkb.layout = "us,ru";
  };

  console.keyMap = "us";

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
  };

  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    bzip2
    cargo
    cmake
    gcc
    gdbm
    git
    gnumake
    libffi
    mesa
    ncurses
    openssl
    patch
    pyenv
    python3
    python3Packages.pip
    python3Packages.setuptools
    python3Packages.wheel
    readline
    rustc
    sqlite
    tk
    xclip
    xz
    zig
    zlib
  ];

  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];

  stylix.enable = true;
  stylix.autoEnable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
  stylix.polarity = "dark";

  # Kanata

  services.kanata = kanata;

  systemd.services.kanata-internalKeyboard.serviceConfig = {
    SupplementaryGroups = [
      "input"
      "uinput"
    ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  system.stateVersion = "25.05";
}

