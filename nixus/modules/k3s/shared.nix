# shared.nix
{ lib, ... }:

with lib;

{
  options.nixus.k3s = {
    enable = mkEnableOption "Nixus K3s module";

    clusterName = mkOption {
      type = types.str;
      default = "nixus-k3s-cluster";
      description = "The name of the K3s cluster";
    };

    serverAddress = mkOption {
      type = types.str;
      description = "The IP address of the K3s server node";
    };

    tokenFile = mkOption {
      type = types.path;
      description = "Path to the file containing the K3s token";
    };

    nodeType = mkOption {
      type = types.enum [
        "server"
        "agent"
      ];
      description = "The type of the K3s node (server or agent)";
    };

    extraFlags = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Extra flags to pass to the K3s binary";
    };
  };
}
