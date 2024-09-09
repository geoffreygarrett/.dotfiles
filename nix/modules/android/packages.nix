{ pkgs }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs; };
in shared-packages ++ [
  #  which
  #  fswatch
  #  dockutil
  #  tailscale-ui
  #  hammerspoon
]
