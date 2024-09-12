{ pkgs }:
with pkgs;
let
  shared-packages = import ./default.nix { inherit pkgs; };
in
shared-packages
++ [
  qemu
  tailscale # (Reqires root, breaks NixOnDroid), no access to netif's.
]
