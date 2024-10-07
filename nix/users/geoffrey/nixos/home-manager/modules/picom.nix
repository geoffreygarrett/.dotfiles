{
  config,
  lib,
  pkgs,
  ...
}:

{

  services.picom = {
    enable = true;
    settings = {
      # Disable animations to improve performance
      animations = false;

      # Keep corner radius
      corner-radius = 12;

      # Remove unnecessary rounded corners settings
      rounded-corners-exclude = [ ];
      round-borders = 3;
      round-borders-exclude = [ ];
      round-borders-rule = [ ];

      # Disable shadows to improve performance
      shadow = false;
      shadow-radius = 0;
      shadow-opacity = 0.0;
      shadow-offset-x = 0;
      shadow-offset-y = 0;

      # Disable fading and set opacity values for focused and unfocused windows
      fading = false;
      inactive-opacity = 1.0;
      frame-opacity = 1.0;
      inactive-opacity-override = false;
      active-opacity = 1.0;

      focus-exclude = [ ];

      # Opacity rules for Alacritty
      opacity-rule = [
        "100:class_g = 'i3lock'"
        "60:class_g = 'Dunst'"
        "100:class_g = 'Alacritty' && focused"
        "90:class_g = 'Alacritty' && !focused"
      ];

      # Disable blur effects for better performance
      blur = {
        method = "none";
        strength = 0;
        background = false;
        background-frame = false;
        background-fixed = false;
      };

      blur-background-exclude = [ ];

      # Use xrender backend for better compatibility and performance
      backend = "xrender";

      # Disable vsync to avoid synchronization issues
      vsync = false;

      # Keep these settings for window focus behavior
      mark-wmwin-focused = true;
      mark-ovredir-focused = true;
      detect-rounded-corners = false;
      detect-client-opacity = false;
      detect-transient = true;
      detect-client-leader = true;
      use-damage = true; # Keep this for performance optimization
      log-level = "warn"; # Reduce log verbosity

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
