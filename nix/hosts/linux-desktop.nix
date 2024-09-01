{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "geoffrey";
  home.homeDirectory = "/home/geoffrey";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Packages specific to this host
  home.packages = with pkgs; [
    # Add any packages specific to this machine
    neofetch
    htop
    # Add more packages as needed
  ];

  # Host-specific configurations
  # For example, if you want to set some environment variables:
  home.sessionVariables = {
    EDITOR = "vim";
    BROWSER = "firefox";
  };

  # You can also include other modules or configurations specific to this host
  # imports = [ ./some-other-config.nix ];
}