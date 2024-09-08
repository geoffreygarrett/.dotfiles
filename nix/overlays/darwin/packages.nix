{ lib, ... }:

self: super: {
  # Darwin-specific packages

  tailscale-ui = if super.stdenv.isDarwin then super.callPackage ../../packages/darwin/tailscale-ui.nix { } else null;
  hammerspoon = if super.stdenv.isDarwin then super.callPackage ../../packages/darwin/hammerspoon.nix { } else null;
}
