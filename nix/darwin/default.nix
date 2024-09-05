{ pkgs, ... }:
let
  hammerspoon =
    import ./hammerspoon.nix { inherit (pkgs) lib stdenvNoCC fetchurl unzip; };
in
{ home.packages = with pkgs; [ hammerspoon ]; }
