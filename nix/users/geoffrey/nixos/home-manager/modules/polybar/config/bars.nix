{
  pkgs,
  lib,
  config,
  base16,
}:
{
  "bar/main-left" = {
    monitor = "DP-0";
    width = "100%";
    height = 28;
    radius = 0;
    background = "#${base16.base00}";
    foreground = "#${base16.base05}";
    line-size = 2;
    border-size = 0;
    padding = 1;
    module-margin = 1;
    font-0 = "JetBrainsMono Nerd Font:style=Regular:size=10;2";
    font-1 = "JetBrainsMono Nerd Font:style=Bold:size=10;2";
    font-2 = "JetBrainsMono Nerd Font:size=12;3";
    modules-left = "bspwm";
    modules-center = "date";
    modules-right = "tray pulseaudio brightness memory cpu battery spotify-volume spotify spotify-prev spotify-play-pause spotify-next";
    cursor-click = "pointer";
    enable-ipc = true;
  };
  "bar/main-right" = {
    monitor = "DP-4";
    width = "100%";
    height = 28;
    radius = 0;
    background = "#${base16.base00}";
    foreground = "#${base16.base05}";
    line-size = 2;
    border-size = 0;
    padding = 1;
    module-margin = 1;
    font-0 = "JetBrainsMono Nerd Font:style=Regular:size=10;2";
    font-1 = "JetBrainsMono Nerd Font:style=Bold:size=10;2";
    font-2 = "JetBrainsMono Nerd Font:size=12;3";
    modules-left = "bspwm";
    modules-center = "date";
    modules-right = "tray pulseaudio brightness memory cpu battery spotify-volume spotify spotify-prev spotify-play-pause spotify-next";
    cursor-click = "pointer";
    enable-ipc = true;
  };
}
