{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  programs.alacritty.enable = true;
  xdg.configFile."alacritty" = {
    source = "${inputs.self}/dotfiles/alacritty";
    recursive = true;
  };
}
