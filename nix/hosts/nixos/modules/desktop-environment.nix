{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.desktopEnvironment;
in
{
  imports = [
    ./i3.nix
    ./bspwm.nix
    ./gnome.nix
  ];

  options.desktopEnvironment = {
    use = mkOption {
      type = types.enum [
        "bspwm"
        "i3"
        "gnome"
      ];
      default = "gnome";
      description = "Select the desktop environment or window manager to use (bspwm, i3, or gnome)";
    };
  };

  config = mkMerge [
    {
      services.xserver = {
        enable = true;
        displayManager = {
          lightdm.enable = cfg.use != "gnome";
          gdm.enable = cfg.use == "gnome";
        };
      };

      environment.systemPackages = with pkgs; [
        firefox
        vim
        git
      ];
    }

    (mkIf (cfg.use == "bspwm" || cfg.use == "i3") {
      services.picom = {
        enable = true;
        fade = true;
        inactiveOpacity = 0.9;
        shadow = true;
        fadeDelta = 4;
      };

      environment.systemPackages = with pkgs; [
        rofi
        feh
        alacritty
      ];
    })

    (mkIf (cfg.use == "bspwm") {
      windowManager.bspwm.enable = true;
    })

    (mkIf (cfg.use == "i3") {
      windowManager.i3.enable = true;
    })

    (mkIf (cfg.use == "gnome") {
      desktopEnvironment.gnome.enable = true;
    })
  ];
}
