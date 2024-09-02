{ config, pkgs, ... }:

{
  # User and home directory information
  home.username = "geoffreygarrett";
  home.homeDirectory = "/Users/geoffreygarrett";

  # Home Manager state version
  home.stateVersion = "24.05";

  # Enable Home Manager
  programs.home-manager.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Packages specific to this MacBook
  home.packages = with pkgs; [
    neofetch
    htop
    iterm2
    spotify
    # Add more packages as needed
  ];

  # Environment variables specific to this MacBook
  home.sessionVariables = {
    EDITOR = "neovim";
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

  # Host-specific settings (e.g., Mac-specific tools, display settings, etc.)
  # You can include other modules or configurations specific to this host
  # imports = [ ./some-other-config.nix ];
}
