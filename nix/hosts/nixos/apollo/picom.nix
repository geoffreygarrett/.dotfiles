{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.picom = {
    enable = true;
    vSync = true;
    backend = "glx";
    settings = {
      shadow = false;
      fading = false;
      blur = {
        method = "none";
      };
      opacity-rule = [
        "90:class_g = 'Alacritty'"
        "95:class_g = 'Rofi'"
      ];
      use-damage = true;
      log-level = "warn";
      wintypes = {
        tooltip = {
          opacity = 0.95;
        };
        popup_menu = {
          opacity = 0.95;
        };
        dropdown_menu = {
          opacity = 0.95;
        };
      };
    };
  };
}
