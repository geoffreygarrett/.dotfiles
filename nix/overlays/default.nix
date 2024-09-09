{ lib, nixgl, ... }:

self: super: {
  tailscale-ui =
    if super.stdenv.isDarwin then
      super.callPackage ../packages/darwin/tailscale-ui.nix { inherit lib; }
    else
      null;
  hammerspoon =
    if super.stdenv.isDarwin then
      super.callPackage ../packages/darwin/hammerspoon.nix { inherit lib; }
    else
      null;
  nixgl =
    if super.stdenv.isLinux && builtins.getEnv "TERMUX_APP__PACKAGE_NAME" == "" then
      nixgl.overlays.default self super
    else
      null;
}
