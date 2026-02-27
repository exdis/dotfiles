{ config, lib, pkgs, ... }:

let
  sdkPath = "/home/exdis/dev/playdate-sdk";

  commonPkgs = with pkgs; [
    libpng
    zlib
    stdenv.cc.cc.lib
  ];

  simulatorPkgs = with pkgs; [
    gtk3
    gdk-pixbuf
    pango
    cairo
    glib
    webkitgtk_4_1
    xorg.libX11
    libxkbcommon
    udev
  ];

  sdkEnv = ''
    export PLAYDATE_SDK_PATH="${sdkPath}"
  '';

  pdc = pkgs.buildFHSEnv {
    name = "pdc";
    targetPkgs = _: commonPkgs;
    profile = sdkEnv;
    runScript = "${sdkPath}/bin/pdc";
  };

  pdutil = pkgs.buildFHSEnv {
    name = "pdutil";
    targetPkgs = _: commonPkgs;
    profile = sdkEnv;
    runScript = "${sdkPath}/bin/pdutil";
  };

  PlaydateSimulator = pkgs.buildFHSEnv {
    name = "PlaydateSimulator";
    targetPkgs = _: commonPkgs ++ simulatorPkgs;
    profile = sdkEnv;
    runScript = "${sdkPath}/bin/PlaydateSimulator";
  };

in {
  environment.systemPackages = [
    pdc
    pdutil
    PlaydateSimulator
  ];

  environment.sessionVariables.PLAYDATE_SDK_PATH = sdkPath;

  boot.kernelModules = [ "cdc_acm" ];

  services.udisks2.enable = true;

  services.udev.extraRules = ''
    KERNEL=="ttyACM[0-9]*",MODE="0666"
  '';
}
