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
    #inputs.xremap-flake.nixosModules.default

    # Dependencies across my nixos modules
    ../../modules/shared/secrets.nix
  ];

  nix.settings = {
    trusted-public-keys = [
      # geoffrey@apollo
      "builder-name:4w+NIGfO2WFJ6xKs4JaPoiUcxjm4YDG8ycLt3M67uBA=%"
    ];
  };
}
