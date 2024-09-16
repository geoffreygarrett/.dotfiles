{ pkgs }:
with pkgs;
let
  shared-packages = import ../linux/packages.nix { inherit pkgs; };
in
shared-packages
++ [
  # killall
  # diffutils
  # findutils
  # utillinux
  # tzdata
  # hostname
]
