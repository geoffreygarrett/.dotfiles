{ config, pkgs, lib, ... }: {
  home.stateVersion = "22.11";  # Define state version
  imports = [
    ./alacritty.nix
  ];
  home.username = "geoffrey";
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/geoffreygarrett" else "/home/geoffrey";

  # Add common packages
  home.packages = with pkgs; [
    ripgrep
    fd
    jq
    tree
  ];

  programs.home-manager.enable = true;
}
