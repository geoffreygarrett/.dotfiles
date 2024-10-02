{
  config,
  user,
  pkgs,
  ...
}:
let
  icon-files = import ../shared/files/icons.nix { inherit user pkgs; };
in
icon-files // { }
