{ config, pkgs, lib, ... }:

{
  # Ensure Zellij is installed
  home.packages = with pkgs; [
    zellij
  ];

  # Configure Zellij if necessary
  programs.zellij = {
    enable = true;

    # Optionally, define any configuration settings or custom session layouts
    # This example assumes you want to include a custom layout file.
    configFile = "${config.home.homeDirectory}/.config/zellij/config.kdl";
  };

  # Example to manage a custom layout
  home.file = {
    ".config/zellij/config.kdl".text = ''
      # Example Zellij layout configuration
      layout {
        pane split_direction="horizontal" {
          children {
            pane {
              command = "htop"
            }
            pane {
              command = "bash"
            }
          }
        }
      }
    '';
  };
}
