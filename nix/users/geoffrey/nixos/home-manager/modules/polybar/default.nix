{
  pkgs,
  lib,
  config,
  ...
}:

let
  modules = import ./config/modules {
    inherit
      pkgs
      lib
      config
      base16
      ;
  };
  base16 = config.colorScheme.palette;
  bar = {
    width = "100%";
    height = 32;
    radius = 0;
    background = "#${base16.base01}";
    foreground = "#${base16.base05}";
    line-size = 2;
    border-size = 0;
    padding = 1;
    module-margin = 1;
    font-0 = "JetBrainsMono Nerd Font:style=Regular:size=10;2";
    font-1 = "JetBrainsMono Nerd Font:style=Bold:size=10;2";
    font-2 = "JetBrainsMono Nerd Font:size=12;3";
    cursor-click = "pointer";
    enable-ipc = true;
  };
  brightness-control = import ./config/modules/scripts/brightness-control.nix { inherit pkgs; };
in
{
  home.packages = [
    brightness-control
  ];
  services.polybar = {
    enable = true;
    package = pkgs.polybar.override {
      # pulseSupport = true;
      # nlSupport = true;
      alsaSupport = true;
      pulseSupport = true;
      i3Support = true;
    };
    config = lib.mkMerge [
      modules
      {
        "bar/main-left" = bar // {
          monitor = "DP-4";
          modules-left = "launcher bspwm";
          modules-center = "date popup-calendar";
          modules-right = "tray pulseaudio brightness memory cpu battery spotify-volume spotify spotify-prev spotify-play-pause spotify-next sysmenu";
        };

        "bar/main-right" = bar // {
          monitor = "DP-0";
          modules-left = "bspwm";
          bottom = true;
        };
      }
    ];
    script = ''
      polybar main-left &
      polybar main-right &
    '';
  };

}
