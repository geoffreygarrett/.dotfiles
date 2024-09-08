{ lib, nixgl, ... }:

self: super: {
  nixpkgs.overlays = [
    # Darwin-specific overlay
    (final: prev: {
      tailscale-ui = if final.stdenv.isDarwin then final.callPackage ./darwin/packages/tailscale-ui.nix { inherit lib; } else null;
      hammerspoon = if final.stdenv.isDarwin then final.callPackage ./darwin/packages/hammerspoon.nix { inherit lib; } else null;
    }),

    # Linux-specific overlay
    (final: prev: {
      nixgl =
        if final.stdenv.isLinux && builtins.getEnv "TERMUX_APP__PACKAGE_NAME" == ""
        then nixgl.overlays.default final prev
        else null;
    })
  ];
}
