{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.windowManager.bspwm;
  screens = [
    {
      output = "DP-1";
      mode = "2560x1440";
      rate = "144";
      primary = true;
    }
    {
      output = "HDMI-2";
      mode = "3840x2160";
      rate = "60";
      primary = false;
    }
  ];
in
{
  options.windowManager.bspwm = {
    enable = mkEnableOption "bspwm window manager";
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      displayManager = {
        lightdm.enable = true;
        sessionCommands = ''
          ${builtins.concatStringsSep "\n" (
            builtins.map (
              s:
              "${pkgs.xorg.xrandr}/bin/xrandr --output ${s.output} --mode ${s.mode} --rate ${s.rate} ${
                if s.primary then "--primary" else ""
              }"
            ) screens
          )}
          ${pkgs.feh}/bin/feh --bg-scale ${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath}
        '';
      };
      windowManager.bspwm.enable = true;
    };

    sound.enable = true;
    hardware.pulseaudio.enable = true;

    services.picom = {
      enable = true;
      fade = true;
      inactiveOpacity = 0.9;
      shadow = true;
      fadeDelta = 4;
    };

    environment.systemPackages = with pkgs; [
      bspwm
      sxhkd
      dmenu
      rofi
      polybar
      feh
      alacritty
      firefox
      vim
      git
    ];

    home-manager.users.${config.user.name} =
      { pkgs, ... }:
      {
        services.sxhkd.enable = true;
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
        xdg.configFile."bspwm/bspwmrc".text = ''
          #! /bin/sh

          sxhkd &
          polybar &

          bspc monitor ${(builtins.head screens).output} -d I II III IV V
          bspc monitor ${(builtins.elemAt screens 1).output} -d VI VII VIII IX X

          bspc config border_width         2
          bspc config window_gap          12

          bspc config split_ratio          0.52
          bspc config borderless_monocle   true
          bspc config gapless_monocle      true

          bspc rule -a Gimp desktop='^8' state=floating follow=on
          bspc rule -a Firefox desktop='^2'
          bspc rule -a Alacritty desktop='^1'
        '';
        executable = true;

        xdg.configFile."sxhkd/sxhkdrc".text = ''
          # terminal emulator
          super + Return
            alacritty

          # program launcher
          super + @space

          # quit/restart bspwm
          super + alt + {q,r}
            bspc {quit,wm -r}

          # close and kill
          super + {_,shift + }w
            bspc node -{c,k}

          # alternate between the tiled and monocle layout
          super + m
            bspc desktop -l next

          # send the newest marked node to the newest preselected node
          super + y
            bspc node newest.marked.local -n newest.!automatic.local

          # swap the current node and the biggest node
          super + g
            bspc node -s biggest

          # set the window state
          super + {t,shift + t,s,f}
            bspc node -t {tiled,pseudo_tiled,floating,fullscreen}

          # focus the node in the given direction
          super + {_,shift + }{h,j,k,l}
            bspc node -{f,s} {west,south,north,east}

          # focus or send to the given desktop
          super + {_,shift + }{1-9,0}
            bspc {desktop -f,node -d} '^{1-9,10}'
        '';
      };
  };
}
