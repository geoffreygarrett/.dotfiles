{ config, pkgs, lib, inputs, ... }: {
  programs.alacritty = {
    enable = true;
    package =
      if lib.hasPrefix "x86_64-linux" pkgs.system
        || lib.hasPrefix "aarch64-linux" pkgs.system then
        pkgs.writeShellScriptBin "alacritty" ''
          #!/bin/sh
          ${pkgs.nixgl.auto.nixGLDefault}/bin/nixGL ${pkgs.alacritty}/bin/alacritty "$@"
        ''
      else
        pkgs.alacritty;
  };

  xdg.configFile."alacritty" = {
    source = "${inputs.self}/dotfiles/alacritty";
    recursive = true;
  };
}

