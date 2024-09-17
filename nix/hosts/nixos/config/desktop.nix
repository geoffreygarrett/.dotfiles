{ config, pkgs, ... }:

let
  useGnome = true; # Set to false to use BSPWM
  screens = [
    {
      output = "DP-1";
      mode = "2560x1440";
      rate = "144";
      primary = true;
    }
    {
      output = "HDMI-2";
      mode = "3840x2160";
      rate = "60";
      primary = false;
    }
  ];
  primaryScreen = builtins.head (builtins.filter (s: s.primary) screens);
  loginWallpaperPath = ../../../modules/shared/assets/wallpaper/login-wallpaper.png;
in
{
  imports = [
    ./nvidia.nix
    ./vm-passthrough.nix
  ]; # Import the NVIDIA configuration

  services.libinput.enable = true;
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    displayManager =
      if useGnome then
        {
          sessionCommands = ''
            ${builtins.concatStringsSep "\n" (
              builtins.map (
                s:
                "${pkgs.xorg.xrandr}/bin/xrandr --output ${s.output} --mode ${s.mode} --rate ${s.rate} ${
                  if s.primary then "--primary" else ""
                }"
              ) screens
            )}
            ${pkgs.feh}/bin/feh --bg-scale ${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath}
          '';
          gdm = {
            enable = true;
            wayland = false; # Changed to false to use X11 instead of Wayland
            settings = {
              "org/gnome/desktop/background" = {
                picture-uri = "file:///etc/login-wallpaper.png";
                picture-uri-dark = "file:///etc/login-wallpaper.png";
                picture-options = "spanned";
                primary-color = "#000000";
              };
            };
          };
        }
      else
        {
          lightdm = {
            enable = true;
            greeters.slick.enable = true;
            background = loginWallpaperPath;
          };
          defaultSession = "none+bspwm";
          sessionCommands = ''
            ${builtins.concatStringsSep "\n" (
              builtins.map (
                s:
                "${pkgs.xorg.xrandr}/bin/xrandr --output ${s.output} --mode ${s.mode} --rate ${s.rate} ${
                  if s.primary then "--primary" else ""
                }"
              ) screens
            )}
            ${pkgs.feh}/bin/feh --bg-scale ${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath}
          '';
        };
    desktopManager.gnome.enable = useGnome;
    windowManager.bspwm = {
      enable = !useGnome;
      configFile = "/etc/bspwmrc";
      sxhkd.configFile = "/etc/sxhkdrc";
    };
    xkb = {
      layout = "us";
      options = "ctrl:nocaps";
    };
  };

  environment.etc."login-wallpaper.png".source = loginWallpaperPath;

  services.picom.enable = !useGnome;

  environment.systemPackages =
    with pkgs;
    [ firefox ]
    ++ (
      if !useGnome then
        [
          bspwm
          sxhkd
          dmenu
          rofi
          alacritty
          feh
          polybar
          dunst
        ]
      else
        [ ]
    );

  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "ondemand";

  services.acpid.enable = true;

  # Optionally, you can try updating to the latest kernel
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  # Or, if you want to try a specific kernel version:
  # boot.kernelPackages = pkgs.linuxPackages_5_15;
}
