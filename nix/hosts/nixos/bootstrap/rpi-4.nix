{
  inputs,
  lib,
  ...
}:
{
  imports = [
    ./shared.nix
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ];
  # NOTE: To stop zsf from building for the bootstrap.
  # https://discourse.nixos.org/t/how-to-disable-zfs-for-custom-install-image/26828
  boot.supportedFilesystems = lib.mkForce [
    "btrfs"
    "cifs"
    "f2fs"
    "jfs"
    "ntfs"
    "reiserfs"
    "vfat"
    "xfs"
  ];
}
