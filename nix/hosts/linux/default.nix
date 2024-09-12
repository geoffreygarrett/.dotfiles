{
  pkgs,
  config,
  ...
}:
{
  imports = [
    ../../modules/linux/home-manager.nix
    ../../modules/shared/cachix
    ../../modules/shared
    ../../modules/darwin
  ];
}
