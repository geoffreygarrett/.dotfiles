# File: nix/packages/default.nix

{ pkgs ? import <nixpkgs> { } }:

self: super:
let
  makeWrapper = import ./make-wrapper.nix { inherit (super) lib writeShellScriptBin; };

  darwinPackages =
    if super.stdenv.isDarwin then {
      tailscale-ui = super.callPackage ./darwin/tailscale-ui.nix { };
      hammerspoon = super.callPackage ./darwin/hammerspoon.nix { };
    } else { };

in
darwinPackages // {
  # You can add more packages here that are common to all systems
  # For example:
  # my-common-package = super.callPackage ./common/my-package.nix { };
}
