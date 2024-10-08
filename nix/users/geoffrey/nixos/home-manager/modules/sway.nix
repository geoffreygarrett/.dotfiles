# NixOS system-level configuration
# File: /etc/nixos/configuration.nix

{ config, pkgs, ... }:
let
in

{

  # Home Manager user-level configuration
  # File: ~/.config/nixpkgs/home.nix

  # { config, pkgs, ... }:
  #
  # {
  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = "Mod4";
      terminal = "${pkgs.alacritty}/bin/alacritty";
      menu = "${pkgs.wofi}/bin/wofi --show drun";

      input = {
        "*" = {
          xkb_layout = "us";
        };
      };

      bars = [
        {
          command = "${pkgs.waybar}/bin/waybar";
        }
      ];

      keybindings =
        let
          modifier = config.wayland.windowManager.sway.config.modifier;
        in
        {
          "${modifier}+Return" = "exec ${config.wayland.windowManager.sway.config.terminal}";
          "${modifier}+d" = "exec ${config.wayland.windowManager.sway.config.menu}";
          "${modifier}+Shift+q" = "kill";
          "${modifier}+Shift+e" = "exit";
          "Print" = "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy";
        };
    };
  };

  programs.waybar = {
    enable = true;
    # Add your Waybar configuration here
  };

  programs.alacritty = {
    enable = true;
    # Add your Alacritty configuration here
  };

  # Install additional user packages
  home.packages = with pkgs; [
    # firefox
    wofi
  ];
}
