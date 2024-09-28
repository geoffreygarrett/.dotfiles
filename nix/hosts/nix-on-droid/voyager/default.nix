{ pkgs, ... }:
{
  imports = [
    ../shared.nix
  ];

  user = {
    uid = 10403;
    gid = 10403;
  };

  environment.sessionVariables = {
    hostname = "voyager";
    HOSTNAME = "voyager";
    HOST = "voyager";
  };

  environment.packages = [
    (pkgs.writeShellScriptBin "hostname" ''
      echo "voyager"
    '')
  ];
}
