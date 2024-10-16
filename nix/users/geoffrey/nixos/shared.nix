{
  inputs,
  config,
  lib,
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
  sops.defaultSopsFile = lib.mkDefault ../../../../secrets/default.yaml;
  sops.secrets."users/${name}/password" = {
    neededForUsers = true;
  };
  users.users.${name} = lib.mkMerge [
    {
      home = "/home/${name}";
      hashedPasswordFile = config.sops.secrets."users/${name}/password".path;
      extraGroups = [
        "wheel"
        "networkmanager"
        "docker"
        "video"
        # "audio"
        # "input"
        "disk" # NOTE: Possibly needed for Samba
      ];
      isNormalUser = true;
    }
  ];
  users.mutableUsers = false;
  services.gvfs.enable = true;
  security.sudo.wheelNeedsPassword = false;
}
