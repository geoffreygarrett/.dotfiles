{ config, pkgs, lib, home-manager, inputs, ... }:
let user = "geoffreygarrett";
in {
  home.username = "${user}";
  home.stateVersion = "22.11";
  #  imports = [
  #    (import ./modules/darwin/home-manager.nix {
  #      inherit config pkgs lib home-manager inputs user;
  #    })
  #  ];
}
