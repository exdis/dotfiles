{ config, lib, pkgs, inputs, ... }: let
  kanata = import ./modules/kanata.nix;
in
{
  imports =
    [
      ./hardware-configuration.nix
      ./containers/i2pd.nix
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

  time.timeZone = "Europe/Prague";

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
  hardware.bluetooth.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  environment.systemPackages = with pkgs; [
    bun
    bzip2
    cargo
    clang
    clang-tools
    cmake
    jq
    gcc
    gdbm
    git
    gleam
    gnumake
    libffi
    lsof
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
    unzip
    wl-clipboard
    wlr-randr
    xclip
    xz
    zig
    zlib
  ];

  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];

  stylix = {
    enable = true;
    autoEnable = true;
    polarity = "dark";
    base16Scheme = {
      scheme = "Alabaster Dark";
      author = "Base16 / adapted by you";
      base00 = "#0b0c0d"; # Background
      base01 = "#101214";
      base02 = "#1c1f22";
      base03 = "#5b6268";
      base04 = "#8b9499";
      base05 = "#e6eef3"; # Foreground
      base06 = "#f6fbfd";
      base07 = "#ffffff";
      base08 = "#e06c75"; # Red
      base09 = "#d19a66"; # Orange
      base0A = "#e5c07b"; # Yellow
      base0B = "#98c379"; # Green
      base0C = "#56b6c2"; # Cyan
      base0D = "#61afef"; # Blue
      base0E = "#c678dd"; # Purple
      base0F = "#be5046"; # Brown
    };
    # base16Scheme = {
    #   scheme = "Noir Neon Night";
    #   author = "Base16 / tuned for Hyprland noir wallpaper";

    #   # Backgrounds — glossy black, wet asphalt
    #   base00 = "#0b0c0e"; # main background
    #   base01 = "#101316"; # subtle raised surfaces
    #   base02 = "#14171a"; # selections / panels
    #   base03 = "#2c3136"; # comments / outlines

    #   # Foreground — cool, foggy white
    #   base04 = "#8a9197"; # secondary text
    #   base05 = "#d8dee3"; # primary text
    #   base06 = "#eef2f5"; # brighter UI elements
    #   base07 = "#ffffff"; # pure white (sparingly)

    #   # Accents — tuned to wallpaper
    #   base08 = "#d34b4b"; # red — taillights / danger
    #   base09 = "#c9824a"; # orange — warm neon spill
    #   base0A = "#d1b06b"; # yellow — street lamps
    #   base0B = "#7fa874"; # green — muted, realistic
    #   base0C = "#3f6f78"; # cyan — distant city glow
    #   base0D = "#4f7fa6"; # blue — wet asphalt reflection
    #   base0E = "#7a5a8e"; # purple — restrained neon
    #   base0F = "#8c4a42"; # brown — warm shadow tone
    # };
  };

  # Kanata

  services.kanata = kanata;

  systemd.services.kanata-internalKeyboard.serviceConfig = {
    SupplementaryGroups = [
      "input"
      "uinput"
    ];
  };

  # Virtualization

  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true;
  };

  users.extraGroups.vboxusers.members = [ "exdis" ];

  # Nix helper

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/user/exdis";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  system.stateVersion = "25.05";
}

