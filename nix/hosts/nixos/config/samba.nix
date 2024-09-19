{
  config,
  pkgs,
  lib,
  user,
  ...
}:
let
  # The IP address of the NAS on the VPN (I'm using Tailscale)
  nas-vpn-ip = "100.98.196.120";

  # Function to capitalize the first letter of a string
  capitalize =
    str:
    with builtins;
    let
      head = substring 0 1 str;
      tail = substring 1 (stringLength str) str;
    in
    lib.toUpper head + tail;

in
{
  # For mount.cifs, required unless domain name resolution is not needed.
  environment.systemPackages = [ pkgs.cifs-utils ];

  # Setuid wrapper for mount.cifs
  # https://discourse.nixos.org/t/cant-mount-samba-share-as-a-user/49171/2
  security.wrappers."mount.cifs" = {
    program = "mount.cifs";
    source = "${lib.getBin pkgs.cifs-utils}/bin/mount.cifs";
    owner = "root";
    group = "root";
    setuid = true;
  };

  # Make this user the owner of their samba secrets. Done here as the base
  # secrets are set to be compatible with home-manager also. Without this
  # the user will get a permission error when mounting.
  sops.secrets."smb-secrets".owner = "${user}";

  # Merge the default mounts with the additional mounts
  # https://nixos.wiki/wiki/Samba
  fileSystems =
    let
      common = [
        "auto" # Do not mount on boot
        "nofail" # Do not fail if the mount fails
        "x-gvfs-show" # Show in file manager
        "x-systemd.automount" # Mount on access
        "x-systemd.idle-timeout=60"
        "x-systemd.device-timeout=5s"
        "x-systemd.mount-timeout=5s"
        "credentials=${config.sops.secrets.smb-secrets.path}"
        "uid=${toString config.users.users.${user}.uid}"
        "gid=${toString config.users.groups.wheel.gid}"
        "user" # Allow users to mount
        "users" # Allow multiple users to mount
      ];
    in
    {
      "/mnt/share/Personal" = {
        device = "//${nas-vpn-ip}/${capitalize user}";
        fsType = "cifs";
        options = common;
      };
      "/mnt/share/Shared" = {
        device = "//${nas-vpn-ip}/Public";
        fsType = "cifs";
        options = common;
      };
    };
}
