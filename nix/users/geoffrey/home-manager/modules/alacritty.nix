{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.alacritty = {
    enable = true;
    package = pkgs.alacritty;

    settings = {
      window = {
        dimensions = {
          columns = 80;
          lines = 24;
        };
        padding = {
          x = 10;
          y = 10;
        };
        dynamic_padding = false;
        decorations = "none";
        # decorations = "full";
        opacity = 0.95;
        startup_mode = "Windowed";
        title = "Alacritty";
        dynamic_title = true;
        # https://github.com/alacritty/alacritty/issues/7637
        option_as_alt = "Both";
      };
      scrolling = {
        history = 10000;
        multiplier = 3;
      };
      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Medium";
        };
        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Medium Bold";
        };
        italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Medium Italic";
        };
        bold_italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Medium Bold Italic";
        };
        size = 11.0;
        offset = {
          x = 0;
          y = 0;
        };
        glyph_offset = {
          x = 0;
          y = 0;
        };
      };
      env = {
        # Fix for Alacritty + tmux colorscheme clashes.
        # https://www.reddit.com/r/neovim/comments/13thfol/help_same_colorscheme_of_neovim_showing_different/ 
        TERM = "xterm-256color";
      };
      bell = {
        animation = "EaseOutExpo";
        duration = 0;
      };
      selection = {
        save_to_clipboard = false;
      };
      cursor = {
        vi_mode_style = "None";
        thickness = 0.15;
      };
      shell = {
        program = "${pkgs.tmux}/bin/tmux";
        args = [
          "new-session"
          "-A"
          "-s"
          "main"
        ];
      };
      mouse = {
        hide_when_typing = false;
      };
      keyboard.bindings = [
        {
          key = "V";
          mods = "Control|Shift";
          action = "Paste";
        }
        {
          key = "F11";
          mods = "None";
          action = "ToggleFullscreen";
        }
        {
          key = "C";
          mods = "Control|Shift";
          action = "Copy";
        }
        {
          key = "Insert";
          mods = "Shift";
          action = "PasteSelection";
        }
        {
          key = "Key0";
          mods = "Control";
          action = "ResetFontSize";
        }
        {
          key = "Equals";
          mods = "Control";
          action = "IncreaseFontSize";
        }
        {
          key = "Minus";
          mods = "Control";
          action = "DecreaseFontSize";
        }
      ];
      debug = {
        render_timer = false;
        persistent_logging = false;
        log_level = "Warn";
        print_events = false;
      };
      colors = {
        primary = {
          background = "#${config.colorScheme.palette.base00}";
          foreground = "#${config.colorScheme.palette.base04}";
        };
        normal = {
          black = "#${config.colorScheme.palette.base00}";
          red = "#${config.colorScheme.palette.base08}";
          green = "#${config.colorScheme.palette.base0B}";
          yellow = "#${config.colorScheme.palette.base0A}";
          blue = "#${config.colorScheme.palette.base0D}";
          magenta = "#${config.colorScheme.palette.base0E}";
          cyan = "#${config.colorScheme.palette.base0C}";
          white = "#${config.colorScheme.palette.base04}";
        };
        bright = {
          black = "#${config.colorScheme.palette.base03}";
          red = "#${config.colorScheme.palette.base0F}";
          green = "#${config.colorScheme.palette.base0B}";
          yellow = "#${config.colorScheme.palette.base0A}";
          blue = "#${config.colorScheme.palette.base0D}";
          magenta = "#${config.colorScheme.palette.base0E}";
          cyan = "#${config.colorScheme.palette.base0C}";
          white = "#${config.colorScheme.palette.base05}";
        };
        cursor = {
          text = "#${config.colorScheme.palette.base00}";
          cursor = "#${config.colorScheme.palette.base04}";
        };
        selection = {
          text = "#${config.colorScheme.palette.base00}";
          background = "#${config.colorScheme.palette.base04}";
        };
      };
    };
  };
}
