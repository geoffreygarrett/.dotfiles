{ pkgs }:
with pkgs;
let
  shared-packages = import ../shared/packages { inherit pkgs; };
in
shared-packages
++ [
  pinentry-curses
  font-manager
  simplescreenrecorder
  mendeley
  # procps
  # killall
  # diffutils
  # findutils
  # utillinux
  # tzdata
  # hostname
]
