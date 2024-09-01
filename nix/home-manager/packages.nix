{ config, pkgs, ... }:

{
  # Packages to install
  home.packages = with pkgs; [
#    firefox
#    vscode
#    git
#    curl
#    wget
  ];
}