{
  ...
}:
{
  imports = [
    ./shared.nix
  ];
  home-manager = {
    users."geoffrey" = import ./home-manager/server.nix;
  };
}
