{ config, pkgs, ... }:

{
  # Packages to install
  home.packages = with pkgs; [
    pkgs.cargo
    pkgs.rustc
    pkgs.rust-analyzer
    pkgs.gh
    #     viu
    #    firefox
    #    vscode
    #    git
    #    curl
    #    wget
  ];
}
