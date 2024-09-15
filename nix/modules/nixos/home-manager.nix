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
in
{
  imports = [
    ../shared/aliases.nix
    ../shared/secrets.nix
    ../shared/home-manager/programs
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
      font-name = "Roboto 12";
      document-font-name = "Roboto 12";
      monospace-font-name = "JetBrains Mono 10";
      cursor-blink = false;
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
