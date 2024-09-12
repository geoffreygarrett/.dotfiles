# default.nix
{
  homeManagerModules.networkShareMounter = import ./home-manager.nix;
  darwinModules.networkShareMounter = import ./darwin.nix;
  nixosModules.networkShareMounter = import ./nixos.nix;
}
