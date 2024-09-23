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

    home-manager.users.${config.custom.user} =
      { pkgs, ... }:
      {
        xsession.windowManager.bspwm = {
          enable = true;
          settings = {
            border_width = 2;
            window_gap = 12;
            split_ratio = 0.52;
            borderless_monocle = true;
            gapless_monocle = true;
          };
          startupPrograms =
            [
              "sxhkd"
              "polybar"
              "${pkgs.feh}/bin/feh --bg-scale ${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath}"
            ]
            ++ (map (
              d:
              "${pkgs.xorg.xrandr}/bin/xrandr --output ${d.output} --mode ${d.mode} --rate ${d.rate} ${
                if d.primary then "--primary" else ""
              } --pos ${toString d.position.x}x${toString d.position.y} --scale ${toString d.scale}x${toString d.scale} --rotation ${d.rotation}"
            ) cfg.displays);
        };

        services.sxhkd = {
          enable = true;
          keybindings = {
            "super + Return" = "alacritty";
            "super + @space" = "rofi -show drun";
            "super + Escape" = "pkill -USR1 -x sxhkd";
            "super + alt + {q,r}" = "bspc {quit,wm -r}";
            "super + {_,shift + }w" = "bspc node -{c,k}";
            "super + m" = "bspc desktop -l next";
            "super + y" = "bspc node newest.marked.local -n newest.!automatic.local";
            "super + g" = "bspc node -s biggest";
            "super + {t,shift + t,s,f}" = "bspc node -t {tiled,pseudo_tiled,floating,fullscreen}";
            "super + {_,shift + }{h,j,k,l}" = "bspc node -{f,s} {west,south,north,east}";
            "super + {_,shift + }{1-9,0}" = "bspc {desktop -f,node -d} '^{1-9,10}'";
          };
        };

        services.polybar = {
          enable = true;
          script = "polybar &";
          config = {
            "bar/top" = {
              monitor = "\${env:MONITOR:}";
              width = "100%";
              height = 27;
              background = "#222";
              foreground = "#dfdfdf";
              modules-left = "bspwm";
              modules-center = "date";
              modules-right = "pulseaudio battery";
            };
            "module/bspwm" = {
              type = "internal/bspwm";
              label-focused = "%name%";
              label-focused-background = "#3f3f3f";
              label-focused-padding = 2;
              label-occupied = "%name%";
              label-occupied-padding = 2;
              label-empty = "%name%";
              label-empty-foreground = "#44";
              label-empty-padding = 2;
            };
            "module/date" = {
              type = "internal/date";
              interval = 5;
              date = "%Y-%m-%d";
              time = "%H:%M";
              label = "%date% %time%";
            };
            "module/pulseaudio" = {
              type = "internal/pulseaudio";
              format-volume = "<label-volume> <bar-volume>";
              label-volume = "VOL %percentage%%";
              label-volume-foreground = "\${root.foreground}";
            };
            "module/battery" = {
              type = "internal/battery";
              battery = "BAT0";
              adapter = "AC";
              full-at = 98;
              format-charging = "<animation-charging> <label-charging>";
              format-discharging = "<animation-discharging> <label-discharging>";
              format-full-prefix = " ";
              ramp-capacity-0 = "";
              ramp-capacity-1 = "";
              ramp-capacity-2 = "";
            };
          };
        };
      };
  };
}
