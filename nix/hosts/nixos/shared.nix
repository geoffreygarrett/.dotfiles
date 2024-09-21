{ inputs, ... }:

{
  imports = [
    # Disk management
    inputs.disko.nixosModules.disko

    # Secret management
    inputs.sops-nix.nixosModules.default

    # User management
    inputs.home-manager.nixosModules.home-manager

    # Keyboard remapping
    inputs.xremap-flake.nixosModules.default

    #
    # Dependencies across my nixos modules
    ../../modules/shared/secrets.nix
  ];
}
