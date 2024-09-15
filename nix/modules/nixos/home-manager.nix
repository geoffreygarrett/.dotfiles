{
  config,
  pkgs,
  lib,
  home-manager,
  inputs,
  user,
  ...
}:
let

  shared-programs = import ../shared/home-manager.nix {
    inherit
      config
      pkgs
      lib
      home-manager
      inputs
      ;
  };
  secrets = import ./secrets.nix { inherit config pkgs user; };
in
{
  imports = [
    shared-programs
    secrets
  ];
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "${user}";
    homeDirectory = "/home/${user}";
    packages = pkgs.callPackage ./packages.nix { };
    #      file = shared-files // import ./files.nix { inherit user pkgs; };
    stateVersion = "21.05";
  };
}
