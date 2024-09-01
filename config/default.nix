# File: default.nix

{ pkgs, lib, ... }:

let
  alacrittyConfig = builtins.readFile ./alacritty/alacritty.toml;
  zshrc = builtins.readFile ./zsh/.zshrc;
in
{
  config = {
    alacritty = {
      configContent = alacrittyConfig;
    };
    zsh = {
      rc = zshrc;
    };
  };
}
