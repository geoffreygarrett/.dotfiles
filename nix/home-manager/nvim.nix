{ config, pkgs, lib, ... }:
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraConfig = ''
      " Any Vimscript configuration can go here
    '';
  };
    home.packages = [ pkgs.lazygit ];
    xdg.configFile."nvim" = {
      source = ../../dotfiles/nvim;
      recursive = true;
    };
}

