{
  config,
  lib,
  pkgs,
  ...
}:
let
  user = "geoffreygarrett";
in
{
  # Ensure the Syncthing directory exists
  #  system.activationScripts.syncthing-dir = ''
  #    mkdir -p "/Users/${user}/Library/Application Support/Syncthing"
  #  '';
}
