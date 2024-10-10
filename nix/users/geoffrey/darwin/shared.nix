{ inputs, ... }:
let
  name = "geoffrey";
in
{
  imports = [
    ../shared/unix.nix
    inputs.home-manager.darwinModules.home-manager
    inputs.nix-homebrew.darwinModules.nix-homebrew
    inputs.nixvim.nixDarwinModules.nixvim
  ];
  users.users.${name}.home = "/Users/${name}";
  system.keyboard.remapCapsLockToControl = true;
}
