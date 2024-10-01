{
  pkgs,
  lib,
  user,
  ...
}:

let
  colors = {
    background = "#0F111A";
    background-alt = "#181A1F";
    foreground = "#8F93A2";
    primary = "#84ffff";
    secondary = "#c792ea";
    alert = "#ff5370";
    disabled = "#464B5D";
  };

  brightness-control = pkgs.writeShellScriptBin "brightness-control" ''
    set -e

    STEP=5
    MAX_BRIGHTNESS=100
    MIN_BRIGHTNESS=5
    LOCKFILE="/tmp/brightness-lock"
    BRIGHTNESS_FILE="/tmp/brightness-value"

    # Ensure only one instance of the script runs at a time
    if [ -e "$LOCKFILE" ]; then
      exit 0
    fi
    trap 'rm -f "$LOCKFILE"' EXIT
    touch "$LOCKFILE"

    # Use pkgs.xrandr, pkgs.gnugrep, pkgs.coreutils, pkgs.bc from Nix
    XRANDR=${pkgs.xorg.xrandr}/bin/xrandr
    GREP=${pkgs.gnugrep}/bin/grep
    AWK=${pkgs.gawk}/bin/awk
    BC=${pkgs.bc}/bin/bc
    DUNSTIFY=${pkgs.dunst}/bin/dunstify

    # Function to get the current brightness level
    get_brightness() {
      # Read cached brightness value to avoid frequent xrandr calls
      if [ -f "$BRIGHTNESS_FILE" ]; then
        cat "$BRIGHTNESS_FILE"
      else
        current_brightness=$($XRANDR --verbose | $GREP -m 1 -i brightness | $AWK '{print int($2 * 100)}')
        echo "$current_brightness" > "$BRIGHTNESS_FILE"
        echo "$current_brightness"
      fi
    }

    # Function to set the brightness level
    set_brightness() {
      for output in $($XRANDR | $GREP " connected" | cut -f1 -d " "); do
        $XRANDR --output "$output" --brightness $(echo "scale=2; $1 / 100" | $BC)
      done
      # Cache the new brightness value
      echo "$1" > "$BRIGHTNESS_FILE"
    }

    # Function to send a notification and update Polybar with the new brightness level
    notify() {
      brightness=$(get_brightness)
      if [ "$brightness" -ge 80 ]; then
        ramp=" "
      elif [ "$brightness" -ge 60 ]; then
        ramp=" "
      elif [ "$brightness" -ge 40 ]; then
        ramp=" "
      elif [ "$brightness" -ge 20 ]; then
        ramp=" "
      else
        ramp=" "
      fi
      $DUNSTIFY -a "changebrightness" -u low -i display-brightness -h string:x-dunst-stack-tag:brightness \
        -h int:value:"$brightness" "Brightness: $brightness%"

      # Immediately update Polybar with the new brightness level
      echo "$ramp $brightness%" > /tmp/polybar-brightness
      polybar-msg action "#brightness.hook.0"
    }

    # Main case statement for handling brightness controls
    case $1 in
      up)
        new=$(( $(get_brightness) + STEP ))
        [[ $new -gt $MAX_BRIGHTNESS ]] && new=$MAX_BRIGHTNESS
        set_brightness $new
        notify
        ;;
      down)
        new=$(( $(get_brightness) - STEP ))
        [[ $new -lt $MIN_BRIGHTNESS ]] && new=$MIN_BRIGHTNESS
        set_brightness $new
        notify
        ;;
      set)
        if [[ $2 -ge $MIN_BRIGHTNESS && $2 -le $MAX_BRIGHTNESS ]]; then
          set_brightness $2
          notify
        else
          echo "Invalid brightness value. Must be between $MIN_BRIGHTNESS and $MAX_BRIGHTNESS."
          exit 1
        fi
        ;;
      get)
        get_brightness
        ;;
      *)
        echo "Usage: $0 {up|down|set <value>|get}"
        exit 1
        ;;
    esac
  '';
  addOpacity =
    color: opacity:
    let
      a = builtins.floor (255 * opacity);
    in
    "${color}${lib.toHexString (builtins.floor a)}";
  monitor-setup = pkgs.writeShellScriptBin "monitor-setup" ''
    # Set wallpaper
    ${pkgs.feh}/bin/feh --bg-fill ${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath}

    # Restart Polybar
    ${pkgs.procps}/bin/pkill polybar
    ${pkgs.polybar}/bin/polybar main-left &
    ${pkgs.polybar}/bin/polybar main-right &

    # Function to launch app and fullscreen it
    launch_and_fullscreen() {
      local app=$1
      local class=$2
      local desktop=$3

      # Launch the application if it's not running
      if ! pgrep -x $app; then
        $app &
      fi

      # Subscribe to the window event instead of polling
      bspc subscribe node_add | while read -r _ _ wid; do
        if bspc query -N -n $wid | grep -q "$class"; then
          bspc node "$wid" -d $desktop
          bspc node "$wid" -t fullscreen
          break
        fi
      done &
    }


    # Launch and fullscreen applications
    launch_and_fullscreen "${pkgs.firefox}/bin/firefox" firefox '^1'
    launch_and_fullscreen "${pkgs.alacritty}/bin/alacritty" Alacritty '^2'
    launch_and_fullscreen "${pkgs.spotify}/bin/spotify" Spotify '^3'

    # Ensure the first desktop is focused at the end
    ${pkgs.bspwm}/bin/bspc desktop '^1' --focus
  '';
in
{
  environment = {
    sessionVariables.GTK_THEME = "Adwaita:dark";
    systemPackages = with pkgs; [
      bspwm
      sxhkd
      rofi
      polybar
      feh
      alacritty
      dunst
      libnotify
      maim
      papirus-icon-theme # Icons for rofi
      xclip
      picom
      playerctl
      wireplumber # For PulseWire
      bc # For brightnessctl
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };
  services.displayManager.defaultSession = "none+bspwm";
  services.redshift.enable = false;
  # services.redshift = {
  #   enable = true; # Or set to false to disable Redshift
  #   temperature = {
  #     day = 5500;
  #     night = 3700;
  #   };

  #   brightness = {
  #     day = "1";
  #     night = "0.8";
  #   };
  #   extraOptions = [
  #     "-v"
  #     "-m randr"
  #   ];
  # };

  # Better support for general peripherals
  services.libinput.enable = true;
  services.xserver = {
    enable = true;
    # Key repeat settings
    # xset r rate 200 35
    # chefs kiss:  xset r rate 200 45
    autoRepeatDelay = 200; # Delay before key repeat starts (in milliseconds)
    autoRepeatInterval = 45; # Interval between key repeats (in milliseconds)
    displayManager = {
      gdm.enable = true;
    };
    windowManager.bspwm.enable = true;

    # displayManager.lightdm = {
    #   enable = true;
    #   greeters.slick.enable = true;
    #
    #   defaultSession = "none+bspwm";
    #   background = ../../../modules/shared/assets/wallpaper/login-wallpaper.png;
    # };
    #
    videoDrivers = [ "nvidia" ];

    # This helps fix tearing of windows for Nvidia cards
    screenSection = ''
      Option       "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
      Option       "AllowIndirectGLXProtocol" "off"
      Option       "TripleBuffer" "on"
    '';
  };
  services.acpid.enable = true;
  home-manager.users.${user} =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {

      gtk = {
        enable = true;
        gtk3.extraConfig = {
          gtk-key-theme-name = "Default";
          gtk-repeat-delay = 200;
          gtk-repeat-interval = 30;
        };
      };

      # Keyboard settings for X11 and some Wayland compositors
      home.keyboard = {
        layout = "us";
        repeat = {
          delay = 200;
          rate = 30;
        };
      };

      dconf.settings = {
        "org/gnome/desktop/peripherals/keyboard" = {
          repeat-interval = lib.hm.gvariant.mkUint32 25;
          delay = lib.hm.gvariant.mkUint32 225;
          repeat = true;
        };
      };

      xsession.windowManager.bspwm = {
        enable = true;
        settings = {
          border_width = 2;
          window_gap = 10;
          split_ratio = 0.52;
          borderless_monocle = true;
          gapless_monocle = true;
          focus_follows_pointer = true;
          pointer_follows_focus = false;
        };
        startupPrograms = [
          "${pkgs.sxhkd}/bin/sxhkd"
          "${monitor-setup}/bin/monitor-setup"
          "${pkgs.autorandr}/bin/autorandr --change"
        ];
        extraConfig = ''
          bspc config normal_border_color "${addOpacity colors.background-alt 0.5}"
          bspc config active_border_color "${addOpacity colors.primary 0.5}"
          bspc config focused_border_color "${addOpacity colors.primary 0.5}"
          bspc config presel_feedback_color "${addOpacity colors.secondary 0.5}"
        '';
      };
      services.sxhkd = {
        enable = true;
        keybindings = {
          # Basic controls
          "super + Return" = "alacritty";
          "super + @space" = "rofi -show drun";
          "super + Escape" = "pkill -USR1 -x sxhkd";
          "super + alt + {q,r}" = "bspc {quit,wm -r}";
          "super + {_,shift + }w" = "bspc node -{c,k}";

          # State/flags
          "super + {t,shift + t,s,f}" = "bspc node -t {tiled,pseudo_tiled,floating,fullscreen}";
          "super + ctrl + {m,x,y,z}" = "bspc node -g {marked,locked,sticky,private}";

          # Focus/swap
          "super + {_,shift + }{h,j,k,l}" = "bspc node -{f,s} {west,south,north,east}";
          "super + {p,b,comma,period}" = "bspc node -f @{parent,brother,first,second}";
          "super + {_,shift + }c" = "bspc node -f {next,prev}.local.!hidden.window";
          "super + bracket{left,right}" = "bspc desktop -f {prev,next}.local";
          "super + {grave,Tab}" = "bspc {node,desktop} -f last";

          # Preselect
          "super + ctrl + {h,j,k,l}" = "bspc node -p {west,south,north,east}";
          "super + ctrl + {1-9}" = "bspc node -o 0.{1-9}";
          "super + ctrl + space" = "bspc node -p cancel";

          # Move/resize
          "super + alt + {h,j,k,l}" = "bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}";
          "super + alt + shift + {h,j,k,l}" = "bspc node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}";
          "super + {Left,Down,Up,Right}" = "bspc node -v {-20 0,0 20,0 -20,20 0}";

          #       # Desktop management
          #       "super + {_,shift + }{1-9,0}" = "bspc {desktop -f,node -d} '^{1-9,10}'";
          #       "super + ctrl + {1-9,0}" = "bspc desktop -s '^{1-9,10}' --follow";
          #       "super + ctrl + shift + {1-9,0}" = "bspc desktop -m '^{1-9,10}' --follow";
          #
          #     # Desktop management
          # "super + {1-3}" = "bspc desktop -f '^{1-3}'";
          # "super + {4-6}" = "bspc desktop -f '^{4-6}'";
          # "super + shift + {1-3}" = "bspc node -d '^{1-3}'";
          # "super + shift + {4-6}" = "bspc node -d '^{4-6}'";

          # Desktop management
          "super + {1-3}" = "bspc desktop -f 'DP-4:^{1-3}'";
          "super + {4-6}" = "bspc desktop -f 'HDMI-1:^{1-3}'";
          "super + shift + {1-3}" = "bspc node -d 'DP-4:^{1-3}'";
          "super + shift + {4-6}" = "bspc node -d 'HDMI-1:^{1-3}'";

          # Monitor focus
          "super + backslash" = "bspc monitor -f next";

          # Move node to next monitor
          "super + shift + backslash" = "bspc node -m next --follow";

          # Advanced window management
          "super + {_,shift + }n" = "bspc node -f {next,prev}.local";
          "super + {_,shift + }m" = "bspc desktop -l {next,prev}";
          "super + y" = "bspc node newest.marked.local -n newest.!automatic.local";
          "super + g" = "bspc node -s biggest.window";

          # Scratchpad (requires additional setup)
          "super + minus" = "scratchpad";
          "super + shift + minus" = "scratchpad -m";

          # Volume control
          "XF86Audio{RaiseVolume,LowerVolume,Mute}" = "pactl set-sink-{volume @DEFAULT_SINK@ {+,-}5%,mute @DEFAULT_SINK@ toggle}";

          # Brightness control
          "XF86MonBrightnessUp" = "${brightness-control}/bin/brightness-control up";
          "XF86MonBrightnessDown" = "${brightness-control}/bin/brightness-control down";

          # Screenshot
          "Print" = "maim -s | xclip -selection clipboard -t image/png";
          "shift + Print" = "maim | xclip -selection clipboard -t image/png";

          # Application shortcuts
          "super + e" = "nautilus";
          "super + b" = "firefox";

          # Polybar
          "super + p" = "polybar-msg cmd toggle";
          "super + shift + p" = "killall polybar; polybar main &";

          # Media control
          "XF86AudioPlay" = "playerctl play-pause";
          "XF86AudioNext" = "playerctl next";
          "XF86AudioPrev" = "playerctl previous";

          # Volume control
          "XF86AudioRaiseVolume" = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
          "XF86AudioLowerVolume" = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          "XF86AudioMute" = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };
      };

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
            modules-right = "tray pulseaudio brightness memory cpu battery spotify-volume spotify spotify-prev spotify-play-pause spotify-next";
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
            modules-right = "tray pulseaudio brightness memory cpu battery spotify-volume spotify spotify-prev spotify-play-pause spotify-next";
            cursor-click = "pointer";
            enable-ipc = true;
          };
          "module/tray" = {
            type = "internal/tray";
            padding = 2;
            background = colors.background;
            foreground = colors.foreground;
            icon-size = 16;
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
            interval = 5; # Increase to 5 seconds
            format-prefix = "󰍛 ";
            format-prefix-foreground = colors.primary;
            label = "%percentage_used:2%%";
          };
          "module/cpu" = {
            type = "internal/cpu";
            interval = 5; # Increase to 5 seconds
            format-prefix = "󰻠 ";
            format-prefix-foreground = colors.primary;
            label = "%percentage:2%%";
          };
          "module/brightness" = {
            type = "custom/script";
            exec = "${pkgs.coreutils}/bin/cat /tmp/polybar-brightness";
            hook-0 = "${pkgs.coreutils}/bin/cat /tmp/polybar-brightness";
            format = "<label>";
            label = "%output%";
            format-foreground = colors.foreground;
            scroll-up = "${brightness-control}/bin/brightness-control up";
            scroll-down = "${brightness-control}/bin/brightness-control down";
            click-left = "${brightness-control}/bin/brightness-control up";
            click-right = "${brightness-control}/bin/brightness-control down";
          };
          "module/spotify" = {
            type = "custom/script";
            exec =
              let
                script = pkgs.writeShellScriptBin "scroll_spotify_status" ''
                  #!/usr/bin/env bash

                  # Fetch the current status and track info from Spotify
                  status=$(${pkgs.playerctl}/bin/playerctl -p spotify status 2>/dev/null || echo "No player")
                  if [ "$status" = "No player" ]; then
                    echo "󰓃 No media"
                    exit 0
                  fi

                  track_info=$(${pkgs.playerctl}/bin/playerctl -p spotify metadata --format '{{artist}} - {{title}}' 2>/dev/null || echo "No media")

                  # Handle edge case: when there's no track info
                  if [ -z "$track_info" ] || [ "$track_info" = "No media" ]; then
                    track_info="No media"
                  fi

                  # Update the output based on the current status
                  case $status in
                    Playing)
                      icon="󰓇"
                      ;;
                    Paused)
                      icon="󰏤"
                      ;;
                    *)
                      icon="󰓃"
                      ;;
                  esac

                  # Output the result directly
                  echo "$icon $track_info"
                '';
              in
              "${script}/bin/scroll_spotify_status";
            format = "<label>";
            label = "%output%";
            format-foreground = colors.foreground;
            interval = 2; # Poll every 2 seconds
          };
          "module/spotify-volume" = {
            type = "custom/script";
            exec =
              let
                script = pkgs.writeShellScriptBin "spotify_volume" ''
                  VOLUME=$(${pkgs.playerctl}/bin/playerctl -p spotify volume 2>/dev/null || echo "N/A")
                  if [ "$VOLUME" != "N/A" ]; then
                    VOLUME_PERCENT=$(printf "%.0f" $(echo "$VOLUME * 100" | ${pkgs.bc}/bin/bc))
                    echo "󰕾 $VOLUME_PERCENT%"
                  else
                    echo "󰕾 N/A"
                  fi
                '';
              in
              "${script}/bin/spotify_volume";
            label = "%output%";
            format = "<label>";
            interval = 1;
            click-left = "${pkgs.playerctl}/bin/playerctl -p spotify volume 0.05+";
            click-right = "${pkgs.playerctl}/bin/playerctl -p spotify volume 0.05-";
            scroll-up = "${pkgs.playerctl}/bin/playerctl -p spotify volume 0.05+";
            scroll-down = "${pkgs.playerctl}/bin/playerctl -p spotify volume 0.05-";
          };
          "module/spotify-prev" = {
            type = "custom/script";
            exec = "echo '󰒮'";
            label = "%output%";
            format = "<label>";
            click-left = "${pkgs.playerctl}/bin/playerctl previous -p spotify";
          };
          "module/spotify-play-pause" = {
            type = "custom/script";
            interval = 1;
            exec =
              let
                play_pause_script = pkgs.writeShellScriptBin "spotify_play_pause_status" ''
                  status=$(playerctl -p spotify status 2>/dev/null)
                  if [ "$status" = "Playing" ]; then
                    echo "󰐊" 
                  elif [ "$status" = "Paused" ]; then
                    echo "󰏤" 
                  else
                    echo "󰓃" 
                  fi
                '';
              in
              "${play_pause_script}/bin/spotify_play_pause_status";
            label = "%output%";
            format = "<label>";
            click-left = "${pkgs.playerctl}/bin/playerctl play-pause -p spotify";
          };
          "module/spotify-next" = {
            type = "custom/script";
            exec = "echo '󰒭'";
            label = "%output%";
            format = "<label>";
            click-left = "${pkgs.playerctl}/bin/playerctl next -p spotify";
          };

          # "module/playerctl" = {
          #   type = "custom/script";
          #   exec =
          #     let
          #       script = pkgs.writeShellScriptBin "playerctl-status" ''
          #         # Function to get player status
          #         get_status() {
          #             playerctl -a metadata --format '{{status}}' 2>/dev/null | head -n1
          #         }
          #         # Function to get current track info
          #         get_track_info() {
          #             playerctl -a metadata --format '{{playerName}}:{{artist}} - {{title}}' 2>/dev/null | head -n1
          #         }
          #         # Function to replace player names with icons
          #         replace_player_name() {
          #             sed -E 's/spotify/󰓇/; s/firefox/󰈹/; s/chromium/󰊯/; s/mpv/󰐊/; s/^([^:]+):/\1 /'
          #         }
          #         # Main logic
          #         status=$(get_status)
          #         track_info=$(get_track_info | replace_player_name)
          #         case $status in
          #             Playing)
          #                 echo " $track_info"
          #                 ;;
          #             Paused)
          #                 echo "󰏤 $track_info"
          #                 ;;
          #             *)
          #                 echo "󰓃 No media"
          #                 ;;
          #         esac
          #       '';
          #     in
          #     "${script}/bin/playerctl-status";
          #   interval = 1;
          #   format = "<label>";
          #   label = "%output:0:50:...%";
          #   format-foreground = colors.foreground;
          #   click-left = "${pkgs.playerctl}/bin/playerctl play-pause";
          #   click-right = "${pkgs.playerctl}/bin/playerctl next";
          #   click-middle = "${pkgs.playerctl}/bin/playerctl previous";
          #   scroll-up = "${pkgs.playerctl}/bin/playerctl position 5+";
          #   scroll-down = "${pkgs.playerctl}/bin/playerctl position 5-";
          # };
        };
      };

      programs.rofi = {
        enable = true;
        extraConfig = {
          modi = "drun,run,window,ssh";
          icon-theme = "Papirus";
          show-icons = true;
          drun-display-format = "{icon} {name}";
          disable-history = false;
          sidebar-mode = true;
        };
        theme =
          let
            inherit (config.lib.formats.rasi) mkLiteral;
          in
          {
            "*" = {
              bg-col = mkLiteral "${colors.background}";
              bg-col-light = mkLiteral "${colors.background-alt}";
              border-col = mkLiteral "${colors.primary}";
              selected-col = mkLiteral "${colors.background-alt}";
              blue = mkLiteral "${colors.primary}";
              fg-col = mkLiteral "${colors.foreground}";
              fg-col2 = mkLiteral "${colors.primary}";
              grey = mkLiteral "${colors.disabled}";
            };

            "element-text, element-icon , mode-switcher" = {
              background-color = mkLiteral "inherit";
              text-color = mkLiteral "inherit";
            };

            "window" = {
              height = mkLiteral "360px";
              border = mkLiteral "3px";
              border-color = mkLiteral "@border-col";
              background-color = mkLiteral "@bg-col";
            };

            "mainbox" = {
              background-color = mkLiteral "@bg-col";
            };

            "inputbar" = {
              children = mkLiteral "[prompt,entry]";
              background-color = mkLiteral "@bg-col";
              border-radius = mkLiteral "5px";
              padding = mkLiteral "2px";
            };

            "prompt" = {
              background-color = mkLiteral "@blue";
              padding = mkLiteral "6px";
              text-color = mkLiteral "@bg-col";
              border-radius = mkLiteral "3px";
              margin = mkLiteral "20px 0px 0px 20px";
            };

            "textbox-prompt-colon" = {
              expand = false;
              str = ":";
            };

            "entry" = {
              padding = mkLiteral "6px";
              margin = mkLiteral "20px 0px 0px 10px";
              text-color = mkLiteral "@fg-col";
              background-color = mkLiteral "@bg-col";
            };

            "listview" = {
              border = mkLiteral "0px 0px 0px";
              padding = mkLiteral "6px 0px 0px";
              margin = mkLiteral "10px 0px 0px 20px";
              columns = 2;
              lines = 5;
              background-color = mkLiteral "@bg-col";
            };

            "element" = {
              padding = mkLiteral "5px";
              background-color = mkLiteral "@bg-col";
              text-color = mkLiteral "@fg-col";
            };

            "element-icon" = {
              size = mkLiteral "25px";
            };

            "element selected" = {
              background-color = mkLiteral "@selected-col";
              text-color = mkLiteral "@fg-col2";
            };

            "mode-switcher" = {
              spacing = 0;
            };

            "button" = {
              padding = mkLiteral "10px";
              background-color = mkLiteral "@bg-col-light";
              text-color = mkLiteral "@grey";
              vertical-align = mkLiteral "0.5";
              horizontal-align = mkLiteral "0.5";
            };

            "button selected" = {
              background-color = mkLiteral "@bg-col";
              text-color = mkLiteral "@blue";
            };
          };
      };

      services.dunst = {
        enable = true;
        settings = {
          global = {
            font = "JetBrains Mono 10";
            markup = "full";
            format = "<b>%s</b>\n%b";
            sort = "yes";
            indicate_hidden = "yes";
            alignment = "left";
            show_age_threshold = 60;
            word_wrap = "yes";
            ignore_newline = "no";
            stack_duplicates = true;
            hide_duplicate_count = false;
            geometry = "300x5-30+20";
            shrink = "no";
            transparency = 10;
            idle_threshold = 120;
            monitor = 0;
            follow = "mouse";
            sticky_history = "yes";
            history_length = 20;
            show_indicators = "yes";
            line_height = 0;
            separator_height = 2;
            padding = 8;
            horizontal_padding = 8;
            separator_color = "frame";
            startup_notification = false;
            frame_width = 2;
            frame_color = colors.primary;
          };
          urgency_low = {
            background = colors.background;
            foreground = colors.foreground;
            timeout = 10;
          };
          urgency_normal = {
            background = colors.background;
            foreground = colors.foreground;
            timeout = 10;
          };
          urgency_critical = {
            background = colors.background;
            foreground = colors.alert;
            frame_color = colors.alert;
            timeout = 0;
          };
        };
      };
    };
}
