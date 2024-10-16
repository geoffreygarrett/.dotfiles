{ pkgs, ... }:
{
  home.packages = with pkgs; [
    alsa-scarlett-gui
  ];
}
