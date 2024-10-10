{
  inputs,
  config,
  ...
}:
let
  name = "geoffrey";
in
{
  imports = [
    ../shared/unix.nix
    inputs.sops-nix.nixosModules.default # Secret management
    inputs.home-manager.nixosModules.home-manager # User management
  ];
  sops.secrets."users/${name}/password" = {
    neededForUsers = true;
  };
  users.users.${name}.home = "/home/${name}";
  users.users.${name}.hashedPasswordFile = config.sops.secrets."users/${name}/password".path;
  users.users.${name}.extraGroups = [
    "wheel"
    "networkmanager"
    "docker"
    "video"
    # "audio"
    # "input"
    # "disk"
  ];
  users.users.${name}.isNormalUser = true;
  users.mutableUsers = false;
  services.gvfs.enable = true;
  security.sudo.wheelNeedsPassword = false;
}
