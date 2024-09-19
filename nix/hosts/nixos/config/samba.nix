{ config, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.cifs-utils ];

  fileSystems = {
    "/mnt/share" = {
      device = "//100.98.196.120/Geoffrey";
      fsType = "cifs";
      options =
        let
          automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
        in
        [ "${automount_opts},credentials=${config.sops.secrets.smb-secrets.path}" ];
    };

    "/mnt/share/Archive" = {
      device = "/mnt/share/Archive";
      fsType = "none";
      options = [ "bind" ];
    };

    "/mnt/share/Brain" = {
      device = "/mnt/share/Brain";
      fsType = "none";
      options = [ "bind" ];
    };

    "/mnt/share/Documents" = {
      device = "/mnt/share/Documents";
      fsType = "none";
      options = [ "bind" ];
    };

    "/mnt/share/Memes" = {
      device = "/mnt/share/Memes";
      fsType = "none";
      options = [ "bind" ];
    };

    "/mnt/share/Pictures" = {
      device = "/mnt/share/Pictures";
      fsType = "none";
      options = [ "bind" ];
    };

    "/mnt/share/Projects" = {
      device = "/mnt/share/Projects";
      fsType = "none";
      options = [ "bind" ];
    };

    "/mnt/share/Sort" = {
      device = "/mnt/share/Sort";
      fsType = "none";
      options = [ "bind" ];
    };

    "/mnt/share/Videos" = {
      device = "/mnt/share/Videos";
      fsType = "none";
      options = [ "bind" ];
    };
  };
}
