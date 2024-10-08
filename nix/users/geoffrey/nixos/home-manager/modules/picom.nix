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
      # Disable animations
      # animations = true;
      # animation-stiffness = 300.0;
      # animation-dampening = 35.0;
      # animation-clamping = false;
      # animation-mass = 1;
      # animation-for-workspace-switch-in = "none";
      # animation-for-workspace-switch-out = "none";
      # animation-for-open-window = "none";
      # animation-for-menu-window = "none";
      # animation-for-transient-window = "none";
      #
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
      # NOTE: I could not get this working with glx. Windows did not refresh and GPU seemed to be receiving reset commands. `xrender` worked, but no round borders.

      backend = "egl";

      # NOTE: Couldn't run vsync at all, but not necessary.
      vsync = false;

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
