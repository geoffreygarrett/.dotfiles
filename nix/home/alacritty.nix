{ config, pkgs, lib, ... }:
{
  programs.alacritty = {
    enable = true;
  };

  xdg.configFile."alacritty" = {
    source = ../../dotfiles/alacritty;
    recursive = true;
  };
}

