{
  inputs,
  keys,
  ...
}:
{
  imports = [
    # ../../../users/geoffrey/nixos/server.nix
    # ../shared.nix
    # inputs.jetpack-nixos.nixosModules.default
    "${inputs.jetpack-nixos}/modules/default.nix"

  ];
  time.timeZone = "Africa/Johannesburg";
  i18n.defaultLocale = "en_GB.UTF-8";
  networking.networkmanager.enable = true;
  services.openssh.enable = true;
  hardware.nvidia-jetpack.enable = true;
  hardware.nvidia-jetpack.som = "orin-nano";
  hardware.nvidia-jetpack.carrierBoard = "devkit";
  hardware.nvidia-jetpack.modesetting.enable = true;
  users.users.root.openssh.authorizedKeys.keys = keys;
  nix.settings = {
    trusted-users = [
      "root"
      "geoffrey"
    ];
    trusted-public-keys = [
      "builder-name:4w+NIGfO0WFJ6xKs4JaPoiUcxjm4YDG8ycLt3M67uBA=%"
    ];
  };
}
