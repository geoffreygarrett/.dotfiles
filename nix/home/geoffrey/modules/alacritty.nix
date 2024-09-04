{ config, pkgs, lib, inputs, ... }:
{
  programs.alacritty = {
    enable = true;
    package = pkgs.writeShellScriptBin "alacritty" ''
      #!/bin/sh
      ${pkgs.nixgl.auto.nixGLDefault}/bin/nixGL ${pkgs.alacritty}/bin/alacritty "$@"
    '';
  };

  xdg.configFile."alacritty" = {
    source = "${inputs.self}/dotfiles/alacritty";
    recursive = true;
  };
}
