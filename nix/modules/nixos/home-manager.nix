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

  dconf.settings = {
    "org/gnome/shell" = {
      favorite-apps = [
        "firefox.desktop"
        "Alacritty.desktop"
        "mendeley-reference-manager.desktop"
      ];
    };
    "org/gnome/desktop/interface" = {
      font-name = "Roboto 12"; # Interface font
      document-font-name = "Roboto 12"; # Document font
      monospace-font-name = "JetBrains Mono 10"; # Monospace font
      cursor-blink = false; # Disable cursor blink
    };
  };
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "${user}";
    homeDirectory = "/home/${user}";
    packages = pkgs.callPackage ./packages.nix { };
    #      file = shared-files // import ./files.nix { inherit user pkgs; };
    stateVersion = "21.05";
  };
}
