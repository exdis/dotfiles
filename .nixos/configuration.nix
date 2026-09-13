{ config, lib, pkgs, inputs, ... }: let
  kanata = import ./modules/kanata.nix;
in
{
  imports =
    [
      ./hardware-configuration.nix
      ./containers/i2pd.nix
      ./modules/playdate.nix
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
    extraGroups = [ "wheel" "kvm" ];
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

  # Graphical login screen, replacing the bare tty1 console login.
  #
  # Enabling regreet pulls in services.greetd with a default_session that runs
  # ReGreet inside cage (a kiosk Wayland compositor) under dbus-run-session, and
  # enables accounts-daemon so it can list users. greetd takes over tty1: it
  # sets services.greetd.settings.terminal.vt = 1, disables autovt@tty1 and
  # Conflicts with getty@tty1 -- which is why the uwsm autostart that used to
  # live in home.nix's programs.fish.loginShellInit is gone; it could never fire
  # again (`uwsm check may-start` only passes on VT 1).
  #
  # Theming is handled by stylix: its regreet target autoEnables on Linux, so
  # the greeter picks up the Alabaster Dark scheme, fonts and cursor from the
  # stylix block below without any extra configuration here.
  #
  # Pick the "Hyprland (uwsm-managed)" entry at the greeter -- that is
  # hyprland-uwsm.desktop, whose Exec is `uwsm start -e -D Hyprland
  # hyprland.desktop`. The plain "Hyprland" entry runs start-hyprland bare and
  # would reintroduce the dead graphical-session.target / broken portal problem.
  services.displayManager.regreet.enable = true;

  # Run ReGreet inside Hyprland rather than the default cage.
  #
  # cage has no way to select an output mode -- it always takes the EDID
  # preferred mode -- which put the greeter on the wrong mode on DP-3. Hyprland
  # takes the same `monitor` line the real session uses, so the greeter comes up
  # at native 3440x1440@175 and the handover into the session is seamless.
  # Everything expensive (animations, blur, shadows) is off; the config just
  # launches ReGreet and exits the compositor when it returns.
  #
  # Written in Lua for the same reason ~/.config/hypr/hyprland.lua is: hyprlang
  # .conf is now the "legacy" format. Verify with:
  #   Hyprland --verify-config -c <the store path in greetd.toml>
  #
  # This assignment overrides the regreet module's own mkDefault, which trips a
  # stylix warning about a custom default_session.command -- expected, and the
  # theming (regreet.css/regreet.toml) is unaffected since it does not depend on
  # which compositor hosts the greeter.
  # Launched through `start-hyprland`, not the `Hyprland` binary directly.
  # Hyprland 0.56 checks for the watchdog fd that start-hyprland passes
  # (`Hyprland --watchdog-fd N`) and throws up an error overlay reading
  # "Hyprland was started without start-hyprland. This is strongly discouraged
  # unless you are in a debugging environment." when it is missing. Arguments
  # after `--` are forwarded to Hyprland. The user session already went through
  # start-hyprland via hyprland.desktop; only the greeter was launching bare.
  services.greetd.settings.default_session.command =
    let
      greeterConfig = pkgs.writeText "greetd-hyprland.lua" ''
        hl.monitor({
            output   = "DP-3",
            mode     = "3440x1440@175",
            position = "0x0",
            scale    = 1,
        })

        hl.config({
            animations = { enabled = false },
            decoration = {
                blur   = { enabled = false },
                shadow = { enabled = false },
            },
            misc = {
                disable_hyprland_logo   = true,
                force_default_wallpaper = 0,
                vrr                     = 0,
            },
            input = {
                kb_layout = "us,ru",
            },
        })

        hl.on("hyprland.start", function()
            hl.exec_cmd("${lib.getExe config.services.displayManager.regreet.package}; ${config.programs.hyprland.package}/bin/hyprctl dispatch exit")
        end)
      '';
    in
    "${lib.getExe' pkgs.dbus "dbus-run-session"} ${lib.getExe' config.programs.hyprland.package "start-hyprland"} -- -c ${greeterConfig}";

  # ReGreet records the last user and their last session in
  # /var/lib/regreet/state.toml, which is why the right entry is preselected
  # after the first login. Seed it so that is declarative rather than a side
  # effect of having logged in once, and so it survives a wipe of /var/lib.
  #
  # Type `f` (not `f+`) writes the file only when it is missing, leaving ReGreet
  # free to keep updating it afterwards. Runs after the regreet module's own
  # "10-regreet" rules, which create the directory.
  #
  # The argument must contain REAL newlines: the tmpfiles module runs it through
  # lib.strings.escapeC, so a literal "\n" here would be re-escaped to "\x5cn"
  # and land in the file as a backslash and an n, producing invalid TOML.
  systemd.tmpfiles.settings."11-regreet-state"."/var/lib/regreet/state.toml".f = {
    user = "greeter";
    group = "greeter";
    mode = "0644";
    argument = ''
      last_user = "exdis"
      [user_to_last_sess]
      exdis = "Hyprland (uwsm-managed)"
    '';
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

  services.yggdrasil = {
    enable = true;

    settings = {
      Peers = [
        "tls://37.205.14.171:993"
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    android-tools
    bun
    bzip2
    cargo
    clang
    clang-tools
    cmake
    dnsutils
    jq
    gcc
    gdbm
    git
    gleam
    gnumake
    libffi
    lsof
    mesa
    nixd
    ncurses
    typescript-language-server
    vscode-langservers-extracted
    openssl
    patch
    pyenv
    pyright
    python3
    python3Packages.pip
    python3Packages.setuptools
    python3Packages.wheel
    readline
    rust-analyzer
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
    zls
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

  virtualisation.docker.enable = true;

  users.extraGroups.docker.members = [ "exdis" ];

  # Nix helper

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/exdis/.nixos";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.05";
}

