# common.nix
{ config, pkgs, ... }:

let
  screens = [
    {
      output = "DP-1";
      mode = "2560x1440";
      rate = "144";
      primary = true;
    }
    {
      output = "HDMI-2";
      mode = "3840x2160";
      rate = "60";
      primary = false;
    }
  ];
  primaryScreen = builtins.head (builtins.filter (s: s.primary) screens);
  loginWallpaperPath = ../../../modules/shared/assets/wallpaper/login-wallpaper.png;
in
{

  environment.etc."login-wallpaper.png".source = loginWallpaperPath;
  services.libinput.enable = true;
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      options = "ctrl:nocaps";
    };
  };
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
  };
  services.acpid.enable = true;
}
