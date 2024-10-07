{
  pkgs,
  ...
}:
{
  imports = [
    ./shared.nix
  ];
  home-manager = {
    users."geoffrey" = import ./home-manager/desktop.nix;
  };
  users.users.geoffrey.packages = with pkgs; [
    nautilus
    baobab
  ];
}
