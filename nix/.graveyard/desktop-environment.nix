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
    ./sway.nix # Make sure to create this file with the Sway-specific configuration
  ];

  options.desktopEnvironment = {
    use = mkOption {
      type = types.enum [
        "bspwm"
        "i3"
        "gnome"
        "sway"
      ];
      default = "gnome";
      description = "Select the desktop environment or window manager to use (bspwm, i3, gnome, or sway)";
    };
  };

  config = mkMerge [
    {
      services.xserver = {
        enable = true;
        displayManager = {
          lightdm.enable = cfg.use != "gnome" && cfg.use != "sway";
          gdm = {
            enable = cfg.use == "gnome" || cfg.use == "sway";
            wayland = cfg.use == "sway";
          };
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
    (mkIf (cfg.use == "sway") {
      programs.sway = {
        enable = true;
        wrapperFeatures.gtk = true;
      };
      environment.systemPackages = with pkgs; [
        waybar
        swaylock
        swayidle
        wl-clipboard
        mako
        alacritty
        wofi
        grim
        slurp
        kanshi
      ];
      security.polkit.enable = true;
      services.gnome.gnome-keyring.enable = true;
      # Sway-specific configuration
      windowManager.sway.enable = true;
      # Waybar configuration
      programs.waybar.enable = true;
      # Allow users to mount removable devices
      services.udisks2.enable = true;
      # Enable brightness control
      programs.light.enable = true;
    })
  ];
}
