{ pkgs, ... }:
{

  services.polybar = {
    enable = true;
    package = pkgs.polybar.override {
      alsaSupport = true;
      pulseSupport = true;
      i3Support = true;
    };
    script = ''
      polybar main-left &
      polybar main-right &
    '';
    config = {

      "bar/main-left" = {
        monitor = "DP-4";
        width = "100%";
        height = 28;
        radius = 0;
        background = colors.background;
        foreground = colors.foreground;
        line-size = 2;
        border-size = 0;
        padding = 1;
        module-margin = 1;
        font-0 = "JetBrainsMono Nerd Font:style=Regular:size=10;2";
        font-1 = "JetBrainsMono Nerd Font:style=Bold:size=10;2";
        font-2 = "JetBrainsMono Nerd Font:size=12;3";
        modules-left = "bspwm";
        modules-center = "date";
        modules-right = "pulseaudio brightness memory cpu battery playerctl";
        tray-position = "right";
        tray-padding = 2;
        cursor-click = "pointer";
        enable-ipc = true;
      };
      "bar/main-right" = {
        monitor = "HDMI-1";
        width = "100%";
        height = 28;
        radius = 0;
        background = colors.background;
        foreground = colors.foreground;
        line-size = 2;
        border-size = 0;
        padding = 1;
        module-margin = 1;
        font-0 = "JetBrainsMono Nerd Font:style=Regular:size=10;2";
        font-1 = "JetBrainsMono Nerd Font:style=Bold:size=10;2";
        font-2 = "JetBrainsMono Nerd Font:size=12;3";
        modules-left = "bspwm";
        modules-center = "date";
        modules-right = "pulseaudio brightness memory cpu battery playerctl";
        tray-position = "right";
        tray-padding = 2;
        cursor-click = "pointer";
        enable-ipc = true;
      };
      # "bar/main" = {
      #   monitor = "\${env:MONITOR:}";
      #   width = "100%";
      #   height = 28;
      #   radius = 0;
      #   background = colors.background;
      #   foreground = colors.foreground;
      #   line-size = 2;
      #   border-size = 0;
      #   padding = 1;
      #   module-margin = 1;
      #   font-0 = "JetBrainsMono Nerd Font:style=Regular:size=10;2";
      #   font-1 = "JetBrainsMono Nerd Font:style=Bold:size=10;2";
      #   font-2 = "JetBrainsMono Nerd Font:size=12;3";
      #   modules-left = "bspwm";
      #   modules-center = "date";
      #   modules-right = "pulseaudio brightness memory cpu battery playerctl";
      #   tray-position = "right";
      #   tray-padding = 2;
      #   cursor-click = "pointer";
      #   enable-ipc = true;
      # };
      # "bar/main-left" = {
      #   monitor = "DP-4";
      #   width = "100%";
      #   height = 28;
      #   radius = 0;
      #   background = colors.background;
      #   foreground = colors.foreground;
      #   line-size = 2;
      #   border-size = 0;
      #   padding = 1;
      #   module-margin = 1;
      #   font-0 = "JetBrainsMono Nerd Font:style=Regular:size=10;2";
      #   font-1 = "JetBrainsMono Nerd Font:style=Bold:size=10;2";
      #   font-2 = "JetBrainsMono Nerd Font:size=12;3";
      #   modules-left = "bspwm";
      #   modules-center = "date";
      #   modules-right = "pulseaudio brightness memory cpu battery playerctl";
      #   tray-position = "right";
      #   tray-padding = 2;
      #   cursor-click = "pointer";
      #   enable-ipc = true;
      # };
      # "bar/main-right" = {
      #   monitor = "HDMI-1";
      #   width = "100%";
      #   height = 28;
      #   radius = 0;
      #   background = colors.background;
      #   foreground = colors.foreground;
      #   line-size = 2;
      #   border-size = 0;
      #   padding = 1;
      #   module-margin = 1;
      #   font-0 = "JetBrainsMono Nerd Font:style=Regular:size=10;2";
      #   font-1 = "JetBrainsMono Nerd Font:style=Bold:size=10;2";
      #   font-2 = "JetBrainsMono Nerd Font:size=12;3";
      #   modules-left = "bspwm";
      #   modules-center = "date";
      #   modules-right = "pulseaudio brightness memory cpu battery playerctl";
      #   tray-position = "right";
      #   tray-padding = 2;
      #   cursor-click = "pointer";
      #   enable-ipc = true;
      # };
      "module/bspwm" = {
        type = "internal/bspwm";
        label-focused = "%name%";
        label-focused-background = colors.background-alt;
        label-focused-underline = colors.primary;
        label-focused-padding = 2;
        label-occupied = "%name%";
        label-occupied-padding = 2;
        label-urgent = "%name%";
        label-urgent-background = colors.alert;
        label-urgent-padding = 2;
        label-empty = "%name%";
        label-empty-foreground = colors.disabled;
        label-empty-padding = 2;
      };
      "module/xwindow" = {
        type = "internal/xwindow";
        label = "%title:0:60:...%";
      };
      "module/date" = {
        type = "internal/date";
        interval = 5;
        date = "%Y-%m-%d";
        time = "%H:%M";
        label = "%date% %time%";
        format-prefix = "󰃰 ";
        format-prefix-foreground = colors.primary;
      };
      "module/pulseaudio" = {
        type = "internal/pulseaudio";
        format-volume = "<ramp-volume> <label-volume>";
        label-volume = "%percentage%%";
        label-muted = "󰝟 muted";
        ramp-volume-0 = "󰕿";
        ramp-volume-1 = "󰖀";
        ramp-volume-2 = "󰕾";
        ramp-volume-foreground = colors.primary;
      };
      "module/memory" = {
        type = "internal/memory";
        interval = 2;
        format-prefix = "󰍛 ";
        format-prefix-foreground = colors.primary;
        label = "%percentage_used:2%%";
      };
      "module/cpu" = {
        type = "internal/cpu";
        interval = 2;
        format-prefix = "󰻠 ";
        format-prefix-foreground = colors.primary;
        label = "%percentage:2%%";
      };
      "module/brightness" = {
        type = "internal/backlight";
        card = "intel_backlight"; # You may need to change this to match your system
        format = "<ramp> <label>";
        label = "%percentage%%";
        ramp-0 = "🌕";
        ramp-1 = "🌔";
        ramp-2 = "🌓";
        ramp-3 = "🌒";
        ramp-4 = "🌑";
      };
      "module/playerctl" = {
        type = "custom/script";
        exec =
          toString (
            pkgs.writeShellScriptBin "playerctl-status" ''
                                
              # Function to get player status
              get_status() {
                  playerctl -a metadata --format '{{status}}' 2>/dev/null | head -n1
              }

              # Function to get current track info
              get_track_info() {
                  playerctl -a metadata --format '{{playerName}}:{{artist}} - {{title}}' 2>/dev/null | head -n1
              }

              # Function to replace player names with icons
              replace_player_name() {
                  sed -E 's/spotify/󰓇/; s/firefox/󰈹/; s/chromium/󰊯/; s/mpv/󰐊/; s/^([^:]+):/\1 /'
              }

              # Main logic
              status=$(get_status)
              track_info=$(get_track_info | replace_player_name)

              case $status in
                  Playing)
                      echo " $track_info"
                      ;;
                  Paused)
                      echo "󰏤 $track_info"
                      ;;
                  *)
                      echo "󰓃 No media"
                      ;;
              esac
            ''
          )
          + "/bin/playerctl-status";
        interval = 1;
        format = "<label>";
        label = "%output:0:50:...%";
        format-foreground = colors.foreground;
        click-left = "${pkgs.playerctl}/bin/playerctl play-pause";
        click-right = "${pkgs.playerctl}/bin/playerctl next";
        click-middle = "${pkgs.playerctl}/bin/playerctl previous";
      };
    };
  };

}
