{ config, lib, ... }:

{
  imports = [
    ./shared.nix
  ];

  config = lib.mkMerge [
    { }

    (lib.mkIf (lib.hasAttr "home-manager" config) {
      home-manager.users.geoffrey = import ./home-manager/default.nix;
    })
  ];
}
