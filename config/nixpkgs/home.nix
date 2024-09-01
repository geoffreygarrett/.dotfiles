# File: ~/.config/nixpkgs/home.nix

{ config, pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  isWSL = isLinux && builtins.pathExists "/proc/sys/fs/binfmt_misc/WSLInterop";
in
{
  home.stateVersion = "22.11";
  
  imports = [
    ./git.nix
    ./alacritty.nix
    ./nvim.nix
    ./nushell.nix
    ./zellij.nix
  ] ++ lib.optional isDarwin ./macos.nix
    ++ lib.optional isLinux ./linux.nix
    ++ lib.optional isWSL ./wsl.nix;

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../secrets/secrets.yaml;
  };

  home = {
    username = "geoffreygarrett";
    homeDirectory = if isDarwin then "/Users/geoffreygarrett" else "/home/geoffreygarrett";
    
    packages = with pkgs; [
      # Add common packages here
      ripgrep
      fd
      jq
      tree
    ];

    file = {
      ".config/nushell/config.nu".source = ./nushell/config.nu;
      ".config/nushell/env.nu".source = ./nushell/env.nu;
      ".config/zellij/config.kdl".source = ./zellij/config.kdl;
    };
  };

  programs = {
    home-manager.enable = true;
    
    neovim = {
      enable = true;
      # Neovim configuration will be managed separately due to its complexity
    };

    nushell = {
      enable = true;
      # Additional Nushell configuration can be added here
    };

    zellij = {
      enable = true;
      # Additional Zellij configuration can be added here
    };
  };

  # Platform-specific configurations can be added in their respective files:
  # macos.nix, linux.nix, wsl.nix
}