{
  config,
  pkgs,
  lib,
  user,
  ...
}:
let
  common-options = [
    "bind"
    "x-gvfs-show"
    "nofail"
  ];
  nas-vpn-ip = "100.98.196.120";
  nas-hostname = "nimbus";

  # Function to capitalize the first letter of a string
  capitalize =
    str:
    with builtins;
    let
      head = substring 0 1 str;
      tail = substring 1 (stringLength str) str;
    in
    lib.toUpper head + tail;

  # Function to generate additional mounts
  mkSubfolderMounts =
    subfolders:
    lib.listToAttrs (
      map (folder: {
        name = "/mnt/${capitalize user}/${folder}";
        value = {
          depends = [ "/mnt/${capitalize user}" ];
          device = "/mnt/${capitalize user}/${folder}";
          fsType = "none";
          options = common-options;
        };
      }) subfolders
    );

  # List of additional subfolders to mount
  subfolders = [
    "Archive"
    "Brain"
    "Documents"
    "Memes"
    "Pictures"
    "Projects"
    "Sort"
    "Videos"
  ];

  # Generate the additional mounts
  additionalMounts = mkSubfolderMounts subfolders;

in
{
  environment.systemPackages = [ pkgs.cifs-utils ];

  # Merge the default mounts with the additional mounts
  fileSystems = lib.mkMerge [
    {
      "/mnt/${capitalize nas-hostname}" = {
        device = "//${nas-vpn-ip}/";
        fsType = "cifs";
        options = [
          "x-gvfs-show"
          "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,user,users"
          "x-systemd.mount-timeout=5s,credentials=${config.sops.secrets.smb-secrets.path}"
        ];
      };
      "/mnt/${capitalize user}" = {
        device = "/mnt/${capitalize nas-hostname}/${user}";
        options = common-options ++ [
          "uid=${toString config.users.users.${user}.uid}"
          "gid=${toString config.users.groups.${config.users.users.${user}.group}.gid}"
        ];
      };
    }
    additionalMounts
  ];
}
