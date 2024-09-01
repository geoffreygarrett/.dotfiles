# File: alacritty.nix

{ config, pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";

      window = {
        dimensions = {
          columns = 80;
          lines = 24;
        };
        padding = {
          x = 10;
          y = 10;
        };
        dynamic_padding = true;
        decorations = "full";
        startup_mode = "Windowed";
        opacity = 0.9;
      };

      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Italic";
        };
        size = 11.0;
      };

      colors = {
        primary = {
          background = "0x1d1f21";
          foreground = "0xc5c8c6";
        };
        normal = {
          black = "0x1d1f21";
          red = "0xcc6666";
          green = "0xb5bd68";
          yellow = "0xf0c674";
          blue = "0x81a2be";
          magenta = "0xb294bb";
          cyan = "0x8abeb7";
          white = "0xc5c8c6";
        };
        bright = {
          black = "0x666666";
          red = "0xd54e53";
          green = "0xb9ca4a";
          yellow = "0xe7c547";
          blue = "0x7aa6da";
          magenta = "0xc397d8";
          cyan = "0x70c0b1";
          white = "0xeaeaea";
        };
      };

      bell = {
        animation = "EaseOutExpo";
        duration = 0;
      };

      mouse = {
        hide_when_typing = false;
      };

      selection = {
        semantic_escape_chars = ",│`|:\"' ()[]{}<>";
        save_to_clipboard = true;
      };

      cursor = {
        style = "Block";
        unfocused_hollow = true;
      };

      live_config_reload = true;
    };
  };
}