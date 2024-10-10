{
  pkgs,
  keys,
  modulesPath,
  ...
}:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  i18n.defaultLocale = "en_GB.UTF-8";
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = keys;
  nix.settings = {
    trusted-users = [ "root" ];
    trusted-public-keys = [
      "builder-name:4w+NIGfO0WFJ6xKs4JaPoiUcxjm4YDG8ycLt3M67uBA=%"
    ];
    substituters = [ "https://cache.nixos.org" ];
    max-jobs = "auto";
  };
  # isoImage.squashfsCompression = "gzip -Xcompression-level 1";
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = [
      "ext4"
      "vfat"
    ];
  };
  hardware.enableAllFirmware = true;
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
  ];
}
