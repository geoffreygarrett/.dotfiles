{
  config,
  lib,
  pkgs,
  user,
  ...
}:

with lib;

let
  cfg = config.windowManager.i3;
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
  options.windowManager.i3 = {
    enable = mkEnableOption "i3 window manager";
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
      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          dmenu
          i3status
          i3lock
          i3blocks
        ];
      };
    };

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
      firefox
      vim
      git
    ];

    home-manager.users.${user} =
      { pkgs, ... }:
      {
        programs.i3status = {
          enable = true;
          general = {
            colors = true;
            interval = 5;
          };
          modules = {
            ipv6.enable = false;
            "wireless _first_".enable = true;
            "battery all".enable = true;
            "disk /".enable = true;
            "load".enable = true;
            "memory".enable = true;
            "tztime local".enable = true;
          };
        };
        xdg.configFile."i3/config".text = ''
          # set mod key
          set $mod Mod4

          # font
          font pango:monospace 8

          # start a terminal
          bindsym $mod+Return exec alacritty

          # kill focused window
          bindsym $mod+Shift+q kill

          # start dmenu (a program launcher)
          bindsym $mod+d exec dmenu_run

          # change focus
          bindsym $mod+j focus left
          bindsym $mod+k focus down
          bindsym $mod+l focus up
          bindsym $mod+semicolon focus right

          # move focused window
          bindsym $mod+Shift+j move left
          bindsym $mod+Shift+k move down
          bindsym $mod+Shift+l move up
          bindsym $mod+Shift+semicolon move right

          # split in horizontal orientation
          bindsym $mod+h split h

          # split in vertical orientation
          bindsym $mod+v split v

          # enter fullscreen mode for the focused container
          bindsym $mod+f fullscreen toggle

          # change container layout (stacked, tabbed, toggle split)
          bindsym $mod+s layout stacking
          bindsym $mod+w layout tabbed
          bindsym $mod+e layout toggle split

          # toggle tiling / floating
          bindsym $mod+Shift+space floating toggle

          # change focus between tiling / floating windows
          bindsym $mod+space focus mode_toggle

          # focus the parent container
          bindsym $mod+a focus parent

          # Define names for default workspaces
          set $ws1 "1"
          set $ws2 "2"
          set $ws3 "3"
          set $ws4 "4"
          set $ws5 "5"
          set $ws6 "6"
          set $ws7 "7"
          set $ws8 "8"
          set $ws9 "9"
          set $ws10 "10"

          # switch to workspace
          bindsym $mod+1 workspace number $ws1
          bindsym $mod+2 workspace number $ws2
          bindsym $mod+3 workspace number $ws3
          bindsym $mod+4 workspace number $ws4
          bindsym $mod+5 workspace number $ws5
          bindsym $mod+6 workspace number $ws6
          bindsym $mod+7 workspace number $ws7
          bindsym $mod+8 workspace number $ws8
          bindsym $mod+9 workspace number $ws9
          bindsym $mod+0 workspace number $ws10

          # move focused container to workspace
          bindsym $mod+Shift+1 move container to workspace number $ws1
          bindsym $mod+Shift+2 move container to workspace number $ws2
          bindsym $mod+Shift+3 move container to workspace number $ws3
          bindsym $mod+Shift+4 move container to workspace number $ws4
          bindsym $mod+Shift+5 move container to workspace number $ws5
          bindsym $mod+Shift+6 move container to workspace number $ws6
          bindsym $mod+Shift+7 move container to workspace number $ws7
          bindsym $mod+Shift+8 move container to workspace number $ws8
          bindsym $mod+Shift+9 move container to workspace number $ws9
          bindsym $mod+Shift+0 move container to workspace number $ws10

          # reload the configuration file
          bindsym $mod+Shift+c reload
          # restart i3 inplace
          bindsym $mod+Shift+r restart
          # exit i3
          bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit'"

          # resize window
          mode "resize" {
            bindsym j resize shrink width 10 px or 10 ppt
            bindsym k resize grow height 10 px or 10 ppt
            bindsym l resize shrink height 10 px or 10 ppt
            bindsym semicolon resize grow width 10 px or 10 ppt

            # back to normal: Enter or Escape or $mod+r
            bindsym Return mode "default"
            bindsym Escape mode "default"
            bindsym $mod+r mode "default"
          }

          bindsym $mod+r mode "resize"

          # Start i3bar to display a workspace bar
          bar {
            status_command i3status
          }

          # Monitor setup
          ${builtins.concatStringsSep "\n" (
            builtins.map (
              s:
              "workspace ${
                toString (
                  builtins.elemAt [
                    "1"
                    "2"
                    "3"
                    "4"
                    "5"
                  ] (if s.primary then 0 else 1)
                )
              } output ${s.output}"
            ) screens
          )}

          # Autostart applications
          exec --no-startup-id picom -b
        '';
        # executable = true;
      };
  };
}
