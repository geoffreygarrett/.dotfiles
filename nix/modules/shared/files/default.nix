{
  config,
  user,
  pkgs,
  ...
}:
let
  icon-files = import ./icons.nix { inherit user pkgs config; };
in
icon-files
// {}
