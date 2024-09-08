# users/geoffrey/home.nix
{ config, lib, pkgs, ... }:

{
  # Geoffrey-specific configurations
  home.packages = with pkgs;
    [
      # Add user-specific packages here
    ];

  # Syncthing configuration for Geoffrey
  services.syncthing = {
    enable = true;
    tray = {
      enable = true;
      command = "syncthingtray";
    };
    extraOptions = { gui = { theme = "dark"; }; };
  };

}
