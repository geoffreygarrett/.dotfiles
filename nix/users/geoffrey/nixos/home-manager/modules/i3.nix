{ config, pkgs, ... }:

let
  base16 = config.colorScheme.palette;
  # Helper function to add opacity to a color
  addOpacity =
    color: opacity:
    let
      rgb = builtins.substring 1 6 color;
      alpha = builtins.toString (builtins.floor (255 * opacity));
    in
    "#${rgb}${alpha}";
  # Original image path in the Nix store
  originalWallpaper = ../../../../../modules/shared/assets/wallpaper/nix-wallpaper-binary-black.png;
  # Create a separate script for wallpaper modification
  modifyWallpaper = pkgs.writeShellScriptBin "modify-wallpaper" ''
    #!${pkgs.bash}/bin/bash
    input="$1"
    output="$2"
    ${pkgs.imagemagick}/bin/magick "$input" \
      \( +clone -fill "#${base16.base00}" -colorize 30 \) -composite \
      \( +clone -fill "#${base16.base01}" -colorize 20 \) -composite \
      \( +clone -fill "#${base16.base05}" -colorize 15 \) -composite \
      \( +clone -fill "#${base16.base0D}" -colorize 10 \) -composite \
      -set colorspace sRGB \
      -modulate 100,110,100 \
      -brightness-contrast -3x25 \
      -level 2%,98% \
      "$output"
  '';
  # Use the script to modify the wallpaper
  modifiedWallpaper =
    pkgs.runCommand "modified-wallpaper"
      {
        buildInputs = [
          pkgs.imagemagick
          modifyWallpaper
        ];
      }
      ''
        mkdir -p $out
        modify-wallpaper ${originalWallpaper} $out/nix-wallpaper-modified.png
      '';
  # Import monitor-setup script (adjust the path as necessary)
  monitor-setup = import ../scripts/monitor-setup.nix { inherit pkgs; };
  # Import brightness-control script
  brightness-control = import ../scripts/brightness-control.nix { inherit pkgs; };
in
{
  xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = "Mod4";
      bars = [ ]; # We'll use a separate bar (like polybar)
      gaps = {
        inner = 10;
        outer = 0;
        smartGaps = true;
        smartBorders = "on";
      };
      window = {
        border = 2;
        titlebar = false;
      };
      floating = {
        border = 2;
        titlebar = false;
      };
      colors = {
        focused = {
          border = "${base16.base0D}";
          background = "${base16.base00}";
          text = "${base16.base05}";
          indicator = "${base16.base0D}";
          childBorder = "${base16.base0D}";
        };
        unfocused = {
          border = "${base16.base01}";
          background = "${base16.base00}";
          text = "${base16.base05}";
          indicator = "${base16.base01}";
          childBorder = "${base16.base01}";
        };
        focusedInactive = {
          border = "${base16.base01}";
          background = "${base16.base00}";
          text = "${base16.base05}";
          indicator = "${base16.base03}";
          childBorder = "${base16.base01}";
        };
        urgent = {
          border = "${base16.base08}";
          background = "${base16.base08}";
          text = "${base16.base00}";
          indicator = "${base16.base08}";
          childBorder = "${base16.base08}";
        };
      };
      keybindings =
        let
          modifier = config.xsession.windowManager.i3.config.modifier;
        in
        {
          "${modifier}+Return" = "exec alacritty";
          "${modifier}+Shift+q" = "kill";
          "${modifier}+d" = "exec rofi -show drun";
          "${modifier}+Shift+c" = "reload";
          "${modifier}+Shift+r" = "restart";
          "${modifier}+Shift+e" = "exec i3-nagbar -t warning -m 'Exit i3?' -b 'Yes' 'i3-msg exit'";
          "${modifier}+Left" = "focus left";
          "${modifier}+Down" = "focus down";
          "${modifier}+Up" = "focus up";
          "${modifier}+Right" = "focus right";
          "${modifier}+Shift+Left" = "move left";
          "${modifier}+Shift+Down" = "move down";
          "${modifier}+Shift+Up" = "move up";
          "${modifier}+Shift+Right" = "move right";
          "${modifier}+h" = "split h";
          "${modifier}+v" = "split v";
          "${modifier}+f" = "fullscreen toggle";
          "${modifier}+s" = "layout stacking";
          "${modifier}+w" = "layout tabbed";
          "${modifier}+e" = "layout toggle split";
          "${modifier}+Shift+space" = "floating toggle";
          "${modifier}+space" = "focus mode_toggle";
          "${modifier}+a" = "focus parent";
          "${modifier}+Shift+minus" = "move scratchpad";
          "${modifier}+minus" = "scratchpad show";
          "${modifier}+1" = "workspace 1";
          "${modifier}+2" = "workspace 2";
          "${modifier}+3" = "workspace 3";
          "${modifier}+4" = "workspace 4";
          "${modifier}+5" = "workspace 5";
          "${modifier}+6" = "workspace 6";
          "${modifier}+Shift+1" = "move container to workspace 1";
          "${modifier}+Shift+2" = "move container to workspace 2";
          "${modifier}+Shift+3" = "move container to workspace 3";
          "${modifier}+Shift+4" = "move container to workspace 4";
          "${modifier}+Shift+5" = "move container to workspace 5";
          "${modifier}+Shift+6" = "move container to workspace 6";
          "${modifier}+r" = "mode resize";
          "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
          "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "XF86MonBrightnessUp" = "exec ${brightness-control}/bin/brightness-control up";
          "XF86MonBrightnessDown" = "exec ${brightness-control}/bin/brightness-control down";
          "Print" = "exec maim -s | xclip -selection clipboard -t image/png";
          "Shift+Print" = "exec maim | xclip -selection clipboard -t image/png";
          "${modifier}+b" = "exec firefox";
          "${modifier}+e" = "exec nautilus";
        };
      modes = {
        resize = {
          Left = "resize shrink width 10 px or 10 ppt";
          Down = "resize grow height 10 px or 10 ppt";
          Up = "resize shrink height 10 px or 10 ppt";
          Right = "resize grow width 10 px or 10 ppt";
          Escape = "mode default";
          Return = "mode default";
        };
      };
      startup = [
        {
          command = "${pkgs.autorandr}/bin/autorandr --change";
          always = true;
          notification = false;
        }
        {
          command = "${monitor-setup}/bin/monitor-setup";
          always = true;
          notification = false;
        }
        {
          command = "${pkgs.feh}/bin/feh --bg-fill ${modifiedWallpaper}/nix-wallpaper-modified.png";
          always = true;
          notification = false;
        }
        {
          command = "${pkgs.picom}/bin/picom";
          always = true;
          notification = false;
        }
        {
          command = "${pkgs.polybar}/bin/polybar";
          always = true;
          notification = false;
        }
      ];
    };
    extraConfig = ''
      # Additional i3 configuration can be added here
    '';
  };

  # Rofi configuration
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
          bg-col = mkLiteral "#${base16.base00}";
          bg-col-light = mkLiteral "#${base16.base01}";
          border-col = mkLiteral "#${base16.base0D}";
          selected-col = mkLiteral "#${base16.base02}";
          blue = mkLiteral "#${base16.base0D}";
          fg-col = mkLiteral "#${base16.base05}";
          fg-col2 = mkLiteral "#${base16.base06}";
          grey = mkLiteral "#${base16.base03}";
        };
        "element-text, element-icon, mode-switcher" = {
          background-color = mkLiteral "inherit";
          text-color = mkLiteral "inherit";
        };
        "window" = {
          height = mkLiteral "360px";
          border = mkLiteral "3px";
          border-color = mkLiteral "@border-col";
          background-color = mkLiteral "@bg-col";
          border-radius = mkLiteral "12px";
          padding = "15px";
        };
        # ... (rest of the Rofi theme configuration)
      };
  };

  # Picom configuration
  services.picom = {
    enable = true;
    settings = {
      corner-radius = 12;
      rounded-corners-exclude = [ ];
      round-borders = 3;
      round-borders-exclude = [ ];
      round-borders-rule = [ ];
      shadow = false;
      fading = false;
      inactive-opacity = 1.0;
      frame-opacity = 1.0;
      inactive-opacity-override = false;
      active-opacity = 1.0;
      focus-exclude = [ ];
      opacity-rule = [
        "100:class_g = 'i3lock'"
        "60:class_g = 'Dunst'"
        "100:class_g = 'Alacritty' && focused"
        "90:class_g = 'Alacritty' && !focused"
      ];
      blur = {
        method = "none";
        strength = 0;
        background = false;
        background-frame = false;
        background-fixed = false;
      };
      backend = "glx";
      vsync = true;
      mark-wmwin-focused = true;
      mark-ovredir-focused = true;
      detect-rounded-corners = true;
      detect-client-opacity = true;
      use-damage = true;
      log-level = "warn";
      wintypes = {
        normal = {
          fade = false;
          shadow = false;
        };
        tooltip = {
          fade = false;
          shadow = false;
          opacity = 0.95;
          focus = true;
          full-shadow = false;
        };
        dock = {
          shadow = false;
        };
        dnd = {
          shadow = false;
        };
        popup_menu = {
          opacity = 1.0;
        };
        dropdown_menu = {
          opacity = 1.0;
        };
      };
    };
  };
}
