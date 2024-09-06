{ config, pkgs, ... }:

{


  home.sessionVariables.PKG_CONFIG_PATH = "${pkgs.pcsclite}/lib/pkgconfig:${pkgs.opensc}/lib/pkgconfig";


  # Packages to install
  home.packages = with pkgs; [

    pkgs.rust-analyzer
    pkgs.sops
    pkgs.fastfetch

    # SECRETS
    pkgs.age
    pkgs.micromamba
    pkgs.nixfmt

    # RUST-SCRIPT
    pkgs.cargo
    pkgs.rustc
    pkgs.libiconv
    pkgs.rust-script
    pkgs.pcsclite
    pkgs.gengetopt
    pkgs.opensc
    pkgs.pkg-config
    pkgs.wireguard-tools
    pkgs.sops

    #    pkgs.pkg-config

    #     viu
    #    firefox
    #    vscode
    #    git
    #    curl
    #    wget
  ];
}
