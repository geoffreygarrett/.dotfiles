{ config, pkgs, ... }:

{
  # Packages to install
  home.packages = with pkgs; [
       pkgs.cargo
       pkgs.rustc
       pkgs.rust-analyzer
#     viu
#    firefox
#    vscode
#    git
#    curl
#    wget
  ];
}