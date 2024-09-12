{
  pkgs,
  config,
  lib,
  ...
}:
let
  shellAliasesConfig = import ./shell-aliases.nix { inherit pkgs lib; };
in
{
  programs.bash.enable = true;
}
