{ config, pkgs, ... }:

{
  # User and home directory information
  home.username = "geoffrey";
  home.homeDirectory = "/home/geoffrey";

  # Home Manager state version
  home.stateVersion = "24.05";

  # Enable Home Manager
  programs.home-manager.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Packages specific to this Linux machine
  home.packages = with pkgs; [
    neofetch
    htop
    firefox
    vlc
    alacritty
    # Add more packages as needed
  ];

  # Environment variables specific to this Linux machine
  home.sessionVariables = {
    EDITOR = "vim";
    BROWSER = "firefox";
    PATH = "${config.home.homeDirectory}/bin:${pkgs.coreutils}/bin:${pkgs.zsh}/bin:$PATH";
  };

  # Zsh configuration
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "zsh-syntax-highlighting" "zsh-autosuggestions" ];
      theme = "agnoster";
    };
  };

  # Host-specific settings (e.g., display manager settings, services, etc.)
  # imports = [ ./some-other-config.nix ];
}
