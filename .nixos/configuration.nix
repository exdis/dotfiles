{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.kernelModules = [ "vboxguest" "vboxsf" "vboxvideo" "uinput" ];

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

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ libglvnd ];
  };

  services.xserver = {
    videoDrivers = [ "nvidia" ];
    xkb.layout = "us,ru";
  };

  console.keyMap = "us";

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
  };

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

  # programs.uwsm.enable = true;
  # programs.uwsm.waylandCompositors.hyprland = {
  #   prettyName = "Hyprland";
  #   comment = "Hyprland compositor managed by UWSM";
  #   binPath = "/run/current-system/sw/bin/Hyprland";
  # };
  #
  # services.displayManager.sddm.enable = true;
  # services.displayManager.sddm.wayland.enable = true;
  # services.displayManager.defaultSession = "hyprland-uwsm";

  programs.firefox.enable = true;

  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    inputs.zen-browser.packages.x86_64-linux.default
    adwaita-icon-theme
    gnome-themes-extra
    bat
    bzip2
    cargo
    cmake
    diff-so-fancy
    eza
    foot
    fzf
    gcc
    gdbm
    ghostty
    git
    gnumake
    kitty
    libffi
    mesa
    nautilus
    ncurses
    neofetch
    nodejs
    oh-my-fish
    openssl
    patch
    pyenv
    python3
    python3Packages.pip
    python3Packages.setuptools
    python3Packages.wheel
    qt6Packages.qt6ct
    readline
    ripgrep
    rofi
    rustc
    sqlite
    telegram-desktop
    tk
    waybar
    wofi
    xclip
    xz
    yadm
    zig
    zlib
    zoxide
  ];

  nixpkgs.config.allowUnfree = true;
  virtualisation.virtualbox.guest = {
    enable = true;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];

  # GTK

  environment.variables = {
    GTK_THEME = "Adwaita:dark";
    GDK_DARK_MODE = "1"; # GTK4 dark mode
  };

  environment.etc."gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name = Adwaita-dark
    gtk-application-prefer-dark-theme = 1
  '';

  environment.etc."gtk-4.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name = Adwaita-dark
    gtk-application-prefer-dark-theme = 1
  '';

  environment.variables = {
    QT_QPA_PLATFORMTHEME = "qt5ct";
  };

  # Stylix

  stylix = {
    enable = true;
    autoEnable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
    image = "/home/exdis/wp.jpg";
  };

  # Kanata

  systemd.services.kanata-internalKeyboard.serviceConfig = {
    SupplementaryGroups = [
      "input"
      "uinput"
    ];
  };

  services.kanata = {
    enable = true;
    keyboards = {
      internalKeyboard = {
        devices = [
	  "/dev/input/by-path/pci-0000:74:00.4-usb-0:2.3:1.1-event-kbd"
	  "/dev/input/by-path/pci-0000:74:00.4-usb-0:2.4:1.0-event-kbd"
	  "/dev/input/by-path/pci-0000:74:00.4-usb-0:2.4:1.2-event-kbd"
        ];
	port = 1234;
        extraDefCfg = "process-unmapped-keys yes danger-enable-cmd yes";
        config = ''
(defsrc
  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10   f11   f12
  grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
  tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
  caps a    s    d    f    g    h    j    k    l    ;    '    ret
  lsft z    x    c    v    b    n    m    ,    .    /    rsft
  lctl lmet lalt           spc            ralt rmet rctl
)

(defvar
  tap-time 200
  hold-time 200

  left-hand-keys (
    q w e r t
    a s d f g
    z x c v b
  )
  right-hand-keys (
    y u i o p
    h j k l ;
    n m , . /
    )
)
(deflayer us
  brdn  brup  _    _    _    _   prev  pp  next  mute  vold  volu
  grv     1    2    3    4    5    6    7    8    9    0    -    =    bspc
  tab     q    w    e    r    t    y    u    i    o    p    [    ]    \
  esc     @a   @s   @d   @f   g    h    @j   @k   @l   @;    '    ret
  @lshift z    x    c    v    b    n    m    ,    .    /    @rshift
  lctl @lmet lalt           spc            ralt @rmet rctl
)

(deflayer nomods
  brdn  brup  _    _    _    _   prev  pp  next  mute  vold  volu
  grv     1    2    3    4    5    6    7    8    9    0    -    =    bspc
  tab     q    w    e    r    t    y    u    i    o    p    [    ]    \
  esc     a    s    d    f    g    h    j    k    l    ;    '    ret
  @lshift z    x    c    v    b    n    m    ,    .    /    @rshift
  lctl @lmet lalt           spc            ralt @rmet rctl
)

(deflayer numpad
  brdn  brup  _    _    _    _   prev  pp  next  mute  vold  volu
  grv     1    2    3    4    5    6    7    8    9    0    -    =    bspc
  tab     1    2    3    4    t    y    u    i    o    p    [    ]    \
  esc     5    6    7    8    g    h    j    k    l    ;    '    ret
  @lshift -    =    9    0    b    n    m    ,    .    /    @rshift
  lctl @lmet lalt           spc            ralt @rmet rctl
)

(deflayer nav
  brdn  brup  _    _    _    _   prev  pp  next  mute  vold  volu
  grv     1    2    3    4    5    6    7    8    9    0    -    =    bspc
  tab     q    w    e    r    t    y    u    i    o    p    bspc    ]    \
  esc     a    s    d    f    g    left down up   right ;    '    ret
  @lshift z    x    c    v    b    n    m    ,    .    /    @rshift
  lctl @lmet lalt           spc            ralt @rmet rctl
)

(defalias
  npad (layer-while-held numpad)
)

(defalias
  nnav (layer-while-held nav)
)

(deffakekeys
  to-us (layer-switch us)
)

(defalias
  tap (multi
    (layer-switch nomods)
    (on-idle-fakekey to-us tap 20)
  )

  rmet @npad
  lmet @nnav

  a (tap-hold-release-keys $tap-time $hold-time (multi a @tap)  lctl $left-hand-keys)
  s (tap-hold-release-keys $tap-time $hold-time (multi s @tap) @lmet $left-hand-keys)
  d (tap-hold-release-keys $tap-time $hold-time (multi d @tap)  lsft $left-hand-keys)
  f (tap-hold-release-keys $tap-time $hold-time (multi f @tap)  lmet $left-hand-keys)
  j (tap-hold-release-keys $tap-time $hold-time (multi j @tap)  rmet $right-hand-keys)
  k (tap-hold-release-keys $tap-time $hold-time (multi k @tap)  rsft $right-hand-keys)
  l (tap-hold-release-keys $tap-time $hold-time (multi l @tap) @rmet $right-hand-keys)
  ; (tap-hold-release-keys $tap-time $hold-time (multi ; @tap)  rctl $right-hand-keys)

  lshift (tap-hold-press $tap-time $hold-time C-A-\ lsft)
  rshift (tap-hold-press $tap-time $hold-time C-S-A-\ rsft)
)
	'';
      };
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  system.stateVersion = "25.05";
}

