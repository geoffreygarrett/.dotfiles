{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.bspwm;
in
{
  options.modules.bspwm = {
    enable = mkEnableOption "BSPWM window manager";

    displays = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            output = mkOption { type = types.str; };
            mode = mkOption { type = types.str; };
            rate = mkOption { type = types.str; };
            primary = mkOption {
              type = types.bool;
              default = false;
            };
            position = mkOption {
              type = types.submodule {
                options = {
                  x = mkOption { type = types.int; };
                  y = mkOption { type = types.int; };
                };
              };
            };
            scale = mkOption {
              type = types.float;
              default = 1.0;
            };
            rotation = mkOption {
              type = types.enum [
                "normal"
                "left"
                "right"
                "inverted"
              ];
              default = "normal";
            };
          };
        }
      );
      default = [ ];
      description = "Display configuration for BSPWM";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
        sxhkd
        dmenu
        rofi
        polybar
        feh
        alacritty
      ];
      description = "Extra packages to install for BSPWM";
    };
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      displayManager = {
        gdm = {
          enable = true;
          wayland = false;
        };
        defaultSession = "none+bspwm";
      };
      windowManager.bspwm.enable = true;
    };

    environment.systemPackages = cfg.extraPackages;
  };
}
