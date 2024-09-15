{
  config,
  self,
  pkgs,
  lib,
  home-manager,
  inputs,
  user,
  ...
}:
let

  shared-programs = import ../shared/home-manager/programs {
    inherit
      config
      pkgs
      lib
      home-manager
      inputs
      user
      self
      ;
  };
  secrets = import ../shared/secrets.nix {
    inherit
      self
      config
      pkgs
      user
      ;
  };
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
