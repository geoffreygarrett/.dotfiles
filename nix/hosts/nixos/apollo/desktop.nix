{
  config,
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
  # Function to add opacity to a hex color
  addOpacity =
    color: opacity:
    let
      # r = lib.toInt ("16#" + builtins.substring 1 2 color);
      # g = lib.toInt ("16#" + builtins.substring 3 2 color);
      # b = lib.toInt ("16#" + builtins.substring 5 2 color);
      a = builtins.floor (255 * opacity);
    in
    "${color}${lib.toHexString (builtins.floor a)}";
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
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  services.xserver = {
    enable = true;
    # Key repeat settings
    autoRepeatDelay = 225; # Delay before key repeat starts (in milliseconds)
    autoRepeatInterval = 30; # Interval between key repeats (in milliseconds)
    displayManager = {
      gdm.enable = true;
      defaultSession = "none+bspwm";
    };
    windowManager.bspwm.enable = true;

    videoDrivers = [ "nvidia" ];

    # Better support for general peripherals
    libinput.enable = true;

    # This helps fix tearing of windows for Nvidia cards
    screenSection = ''
      Option       "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
      Option       "AllowIndirectGLXProtocol" "off"
      Option       "TripleBuffer" "on"
    '';
  };

  services.picom = {
    enable = true;
    fade = true;
    inactiveOpacity = 0.85;
    activeOpacity = 1.0;
    fadeSteps = [
      3.0e-2
      3.0e-2
    ];
    fadeDelta = 4;
    shadow = true;
    shadowOpacity = 0.75;
    shadowOffsets = [
      (-7)
      (-7)
    ];
    shadowExclude = [
      "name = 'Notification'"
      "class_g = 'Conky'"
      "class_g ?= 'Notify-osd'"
      "class_g = 'Cairo-clock'"
      "_GTK_FRAME_EXTENTS@:c"
      "class_g ?= 'firefox' && argb"
    ];
    settings = {
      shadow-radius = 7;
      corner-radius = 10;
      rounded-corners-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
        "class_g ?= 'firefox' && window_type = 'utility'"
        "class_g ?= 'firefox' && window_type = 'popup_menu'"
      ];
      round-borders = 1;
      round-borders-exclude = [
        "class_g ?= 'firefox' && window_type = 'utility'"
        "class_g ?= 'firefox' && window_type = 'popup_menu'"
      ];
      blur = {
        method = "dual_kawase";
        strength = 5;
        background = false;
        background-frame = false;
        background-fixed = false;
      };
      blur-background-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
        "_GTK_FRAME_EXTENTS@:c"
        "class_g ?= 'firefox' && window_type = 'utility'"
        "class_g ?= 'firefox' && window_type = 'popup_menu'"
      ];
    };
  };
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
          "sxhkd"
          "polybar"
          "${pkgs.feh}/bin/feh --bg-fill ${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath}"
          "dunst"
        ];
        extraConfig = ''
          bspc monitor -d I II III IV
          # V VI VII VIII IX X
          bspc config normal_border_color "${addOpacity colors.background-alt 0.5}"
          bspc config active_border_color "${addOpacity colors.primary 0.5}"
          bspc config focused_border_color "${addOpacity colors.primary 0.5}"
          bspc config presel_feedback_color "${addOpacity colors.secondary 0.5}"

          # Set default desktops for Firefox and Alacritty
          bspc rule -a Firefox desktop='^1' follow=on focus=on
          bspc rule -a Alacritty desktop='^2' follow=on focus=on
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

          # Desktop management
          "super + {_,shift + }{1-9,0}" = "bspc {desktop -f,node -d} '^{1-9,10}'";
          "super + ctrl + {1-9,0}" = "bspc desktop -s '^{1-9,10}' --follow";
          "super + ctrl + shift + {1-9,0}" = "bspc desktop -m '^{1-9,10}' --follow";

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
          "XF86MonBrightness{Up,Down}" = "brightnessctl set {+10%,10%-}";

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
          "XF86AudioRaiseVolume" = "pactl set-sink-volume @DEFAULT_SINK@ +5%";
          "XF86AudioLowerVolume" = "pactl set-sink-volume @DEFAULT_SINK@ -5%";
          "XF86AudioMute" = "pactl set-sink-mute @DEFAULT_SINK@ toggle";

          # Brightness control
          "XF86MonBrightnessUp" = "brightnessctl set +10%";
          "XF86MonBrightnessDown" = "brightnessctl set 10%-";
        };
      };

      services.polybar = {
        enable = true;
        package = pkgs.polybar.override {
          alsaSupport = true;
          pulseSupport = true;
          i3Support = true;
        };
        script = "polybar main &";
        config = {
          "bar/main" = {
            monitor = "\${env:MONITOR:}";
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
            modules-right = "pulseaudio brightness memory cpu battery playerctl";
            modules-left = "bspwm";
            modules-center = "date";
            tray-position = "right";
            tray-padding = 2;
            cursor-click = "pointer";
            enable-ipc = true;
          };
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
          # "module/battery" = {
          #   type = "internal/battery";
          #   battery = "BAT0";
          #   adapter = "AC";
          #   full-at = 98;
          #   format-charging = "<animation-charging> <label-charging>";
          #   format-discharging = "<ramp-capacity> <label-discharging>";
          #   format-full-prefix = "󰁹 ";
          #   format-full-prefix-foreground = colors.primary;
          #   ramp-capacity-0 = "󰁺";
          #   ramp-capacity-1 = "󰁻";
          #   ramp-capacity-2 = "󰁼";
          #   ramp-capacity-3 = "󰁽";
          #   ramp-capacity-4 = "󰁾";
          #   ramp-capacity-foreground = colors.primary;
          #   animation-charging-0 = "󰢜";
          #   animation-charging-1 = "󰂆";
          #   animation-charging-2 = "󰂇";
          #   animation-charging-3 = "󰂈";
          #   animation-charging-4 = "󰢝";
          #   animation-charging-foreground = colors.primary;
          #   animation-charging-framerate = 750;
          # };
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
