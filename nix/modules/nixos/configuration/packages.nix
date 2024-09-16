{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    tailscale
    openrgb-with-all-plugins
    gitAndTools.gitFull
    linuxPackages.v4l2loopback
    v4l-utils
    inetutils
    (writeScriptBin "reboot-to-windows" ''
      #!${pkgs.stdenv.shell}
      windows_menu_entry=$(grep menuentry /boot/grub/grub.cfg | grep -i windows | cut -d "'" -f2)
      sudo grub-reboot "$windows_menu_entry" && sudo reboot
    '')
  ];

  programs = {
    firefox.enable = true;
    zsh.enable = true;
  };
}
