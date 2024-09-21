{
  config,
  lib,
  pkgs,
  user,
  ...
}:

with lib;

let
  cfg = config.windowManager.sway;
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
  options.windowManager.sway = {
    enable = mkEnableOption "Sway window manager";
  };

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      firefox
      wl-clipboard
    ];
    home-manager.users.${user} =
      { pkgs, ... }:
      {
        wayland.windowManager.sway = {
          enable = true;
          config = rec {
            modifier = "Mod4";
            terminal = "alacritty";
            menu = "wofi --show drun";

            output = builtins.listToAttrs (
              map (s: {
                name = s.output;
                value = {
                  mode = "${s.mode}@${s.rate}Hz";
                  adaptive_sync = "on";
                } // (if s.primary then { primary = true; } else { });
              }) screens
            );

            input = {
              "*" = {
                xkb_layout = "us";
                repeat_delay = "300";
                repeat_rate = "50";
              };
            };

            startup = [
              { command = "waybar"; }
              { command = "mako"; }
              { command = "kanshi"; }
            ];

            bars = [ ];

            keybindings =
              let
                modifier = config.wayland.windowManager.sway.config.modifier;
              in
              lib.mkOptionDefault {
                "${modifier}+Return" = "exec ${terminal}";
                "${modifier}+w" = "kill";
                "${modifier}+space" = "exec ${menu}";

                "${modifier}+h" = "focus left";
                "${modifier}+j" = "focus down";
                "${modifier}+k" = "focus up";
                "${modifier}+l" = "focus right";

                "${modifier}+Shift+h" = "move left";
                "${modifier}+Shift+j" = "move down";
                "${modifier}+Shift+k" = "move up";
                "${modifier}+Shift+l" = "move right";

                "${modifier}+b" = "splith";
                "${modifier}+v" = "splitv";

                "${modifier}+f" = "fullscreen toggle";
                "${modifier}+Shift+space" = "floating toggle";

                "${modifier}+1" = "workspace number 1";
                "${modifier}+2" = "workspace number 2";
                "${modifier}+3" = "workspace number 3";
                "${modifier}+4" = "workspace number 4";
                "${modifier}+5" = "workspace number 5";

                "${modifier}+Shift+1" = "move container to workspace number 1";
                "${modifier}+Shift+2" = "move container to workspace number 2";
                "${modifier}+Shift+3" = "move container to workspace number 3";
                "${modifier}+Shift+4" = "move container to workspace number 4";
                "${modifier}+Shift+5" = "move container to workspace number 5";

                "XF86MonBrightnessDown" = "exec light -U 10";
                "XF86MonBrightnessUp" = "exec light -A 10";

                "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
                "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
                "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
              };
          };
        };

        programs.waybar = {
          enable = true;
          settings = [
            {
              height = 30;
              layer = "top";
              position = "bottom";
              tray = {
                spacing = 10;
              };
              modules-center = [ "sway/window" ];
              modules-left = [
                "sway/workspaces"
                "sway/mode"
              ];
              modules-right = [
                "pulseaudio"
                "network"
                "cpu"
                "memory"
                "temperature"
                "clock"
                "tray"
              ];
              clock = {
                format-alt = "{:%Y-%m-%d}";
                tooltip-format = "{:%Y-%m-%d | %H:%M}";
              };
              cpu = {
                format = "{usage}% ";
                tooltip = false;
              };
              memory = {
                format = "{}% ";
              };
              network = {
                interval = 1;
                format-alt = "{ifname}: {ipaddr}/{cidr}";
                format-disconnected = "Disconnected ⚠";
                format-ethernet = "{ifname}: {ipaddr}/{cidr}   up: {bandwidthUpBits} down: {bandwidthDownBits}";
                format-linked = "{ifname} (No IP) ";
                format-wifi = "{essid} ({signalStrength}%) ";
              };
              pulseaudio = {
                format = "{volume}% {icon} {format_source}";
                format-bluetooth = "{volume}% {icon} {format_source}";
                format-bluetooth-muted = " {icon} {format_source}";
                format-icons = {
                  car = "";
                  default = [
                    ""
                    ""
                    ""
                  ];
                  handsfree = "";
                  headphones = "";
                  headset = "";
                  phone = "";
                  portable = "";
                };
                format-muted = " {format_source}";
                format-source = "{volume}% ";
                format-source-muted = "";
                on-click = "pavucontrol";
              };
              "sway/mode" = {
                format = ''<span style="italic">{}</span>'';
              };
              temperature = {
                critical-threshold = 80;
                format = "{temperatureC}°C {icon}";
                format-icons = [
                  ""
                  ""
                  ""
                ];
              };
            }
          ];
          style = ''
            * {
              font-family: "DejaVu Sans Mono", "Font Awesome 5 Free";
              font-size: 13px;
            }

            window#waybar {
              background: rgba(43, 48, 59, 0.5);
              border-bottom: 3px solid rgba(100, 114, 125, 0.5);
              color: white;
            }

            #workspaces button {
              padding: 0 5px;
              background: transparent;
              color: white;
              border-bottom: 3px solid transparent;
            }

            #workspaces button.focused {
              background: #64727D;
              border-bottom: 3px solid white;
            }

            #clock, #battery, #cpu, #memory, #network, #pulseaudio, #custom-spotify, #tray, #mode {
              padding: 0 10px;
              margin: 0 5px;
            }

            #clock {
              background-color: #64727D;
            }

            #battery {
              background-color: #ffffff;
              color: black;
            }

            #battery.charging {
              color: white;
              background-color: #26A65B;
            }

            @keyframes blink {
              to {
                background-color: #ffffff;
                color: black;
              }
            }

            #battery.warning:not(.charging) {
              background: #f53c3c;
              color: white;
              animation-name: blink;
              animation-duration: 0.5s;
              animation-timing-function: linear;
              animation-iteration-count: infinite;
              animation-direction: alternate;
            }
          '';
        };
      };
  };
}
