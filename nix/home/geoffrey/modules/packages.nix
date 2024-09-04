{ config, pkgs, ... }:

{
  # Packages to install
  home.packages = with pkgs; [
    pkgs.cargo
    pkgs.rustc
    pkgs.rust-analyzer
    pkgs.sops
    pkgs.fastfetch

    # SECRETS
    pkgs.age
    pkgs.micromamba
    #     viu
    #    firefox
    #    vscode
    #    git
    #    curl
    #    wget
  ];
}
