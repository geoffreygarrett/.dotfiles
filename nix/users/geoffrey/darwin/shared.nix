{ ... }:
let
  name = "geoffrey";
in
{
  imports = [
    ../shared/unix.nix
  ];
  users.users.${name}.home = "/Users/${name}";
  system.keyboard.remapCapsLockToControl = true;
}
