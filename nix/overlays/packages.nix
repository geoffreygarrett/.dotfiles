{ lib, nixgl, ... }:

self: super: {
  nixpkgs.overlays = [
    (final: prev: super.callPackage ./darwin/packages.nix { inherit lib; })
    (final: prev: super.callPackage ./linux/packages.nix { inherit nixgl lib; })
  ];
}
