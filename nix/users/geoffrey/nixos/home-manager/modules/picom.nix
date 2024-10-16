{
  config,
  lib,
  pkgs,
  ...
}:
let
  theme = config.colorScheme.palette;
in

{

  services.picom = {
    enable = true;
    settings = {
      animations = true;
      animation-stiffness = 300.0;
      animation-dampening = 35.0;
      animation-clamping = false;
      animation-mass = 1;
      animation-for-workspace-switch-in = "auto";
      animation-for-workspace-switch-out = "auto";
      animation-for-open-window = "slide-down";
      animation-for-menu-window = "none";
      animation-for-transient-window = "slide-down";

      # Window border settings
      border-width = 2;
      border-color = "#${theme.base0D}"; # Blue color for active window border
      inactive-border-color = "#${theme.base02}"; # Darker shade for inactive window border

      # Keep corner radius
      corner-radius = 12;

      # Remove unnecessary rounded corners settings
      rounded-corners-exclude = [
        "class_i = 'polybar'"
        "class_g = 'i3lock'"
        "class_g = 'Nautilus' && window_type != 'normal'"
      ];
      round-borders = 3;
      round-borders-exclude = [
        "class_g = 'Nautilus' && window_type != 'normal'"
      ];
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
      xrender-sync-fence = false;

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
      backend = "glx";
      vsync = true;

      # Keep these settings for window focus behavior
      mark-wmwin-focused = true;
      mark-ovredir-focused = true;
      detect-rounded-corners = true;
      detect-client-opacity = false;
      detect-transient = true;
      detect-client-leader = true;
      use-damage = false; # Keep this for performance optimization
      log-level = "warn"; # Reduce log verbosity
      experimental-backends = false;
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
