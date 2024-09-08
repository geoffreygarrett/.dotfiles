# File: nix/packages/default.nix

{ pkgs, lib, ... }:

let
  makeWrapper = import ./make-wrapper.nix { inherit lib; inherit (pkgs) writeShellScriptBin; };

  darwinPackages =
    if pkgs.stdenv.isDarwin then {
      tailscale-ui = pkgs.callPackage ./darwin/tailscale-ui.nix { };
      hammerspoon = pkgs.callPackage ./darwin/hammerspoon.nix { };
    } else { };

in
darwinPackages // {
  # You can add more packages here that are common to all systems
  # For example:
  # my-common-package = pkgs.callPackage ./common/my-package.nix { };
}
