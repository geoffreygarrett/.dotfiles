{ ... }:
{
  imports = [
    ./shared.nix
    ./modules/neovim.nix
  ];
  # home-manager = {
  #   users."geoffrey" = import ./home-manager/server.nix;
  # };
}
