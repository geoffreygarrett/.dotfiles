{ pkgs }:
with pkgs;
let
  shared-packages = import ../shared/packages/desktop.nix { inherit pkgs; };
in
shared-packages
++ [
  pinentry-curses
  font-manager
  # procps

  # System
  wmctrl

  # Data recovery
  ddrescueview

  jetbrains.rust-rover
  jetbrains.clion
  jetbrains.pycharm-professional
  # Communication
  simplescreenrecorder
  mendeley
  obsidian
  libreoffice
  #  pcscd https://discourse.nixos.org/t/home-manager-users-can-help-test-gnupg-2-3-1-beta/12692/5
]
