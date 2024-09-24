{ pkgs }:
with pkgs;
let
  shared-packages = import ../../shared/packages/desktop.nix { inherit pkgs; };
in
shared-packages
++ [
  fswatch
  dockutil
]
