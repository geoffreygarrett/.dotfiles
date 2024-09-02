# home-manager/alacritty.nix
{ config, pkgs, lib, ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      import = [ "${config.alacritty.configContent}" ];  # Use the imported config
      font = {
        size = 13;
        normal = {
          family = "JetBrains Mono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "JetBrains Mono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "JetBrains Mono Nerd Font";
          style = "Italic";
        };
        bold_italic = {
          family = "JetBrains Mono Nerd Font";
          style = "Bold Italic";
        };
      };
    };
  };
}
