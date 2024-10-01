{
  config,
  lib,
  pkgs,
  ...
}:

{
  # For X11
  services.xserver = {
    autoRepeatDelay = 200;
    autoRepeatInterval = 25;
  };

  # For GNOME
  services.xserver.desktopManager.gnome = {
    extraGSettingsOverrides = ''
      [org.gnome.desktop.peripherals.keyboard]
      delay=200
      repeat-interval=25
    '';
  };

  # For console (virtual terminals)
  console.keyMap = "us";
  console.keyRate = "25";
  console.keyRepeatDelay = 200;
}
