{ config, pkgs, lib, ... }:

let
  pkgs-unstable = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixpkgs-unstable.tar.gz";
  }) {
    inherit (pkgs.stdenv) system;
  };
in
{
  programs.neovim.package = pkgs-unstable.neovim;
  programs.neovim = {
    enable = true;
    extraConfig = ''
      " Additional Neovim configurations can be placed here
    '';
  };
}
