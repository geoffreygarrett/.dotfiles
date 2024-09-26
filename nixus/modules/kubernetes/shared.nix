{ lib, ... }:

with lib;

{
  options.nixus.kubernetes = {
    enable = mkEnableOption "Nixus Kubernetes module";
    clusterName = mkOption {
      type = types.str;
      default = "nixus-cluster";
      description = "The name of the Kubernetes cluster";
    };
    podNetworkCidr = mkOption {
      type = types.str;
      default = "10.244.0.0/16";
      description = "The CIDR for the pod network";
    };
    serviceNetworkCidr = mkOption {
      type = types.str;
      default = "10.96.0.0/12";
      description = "The CIDR for the service network";
    };
    cniPlugin = mkOption {
      type = types.enum [
        "flannel"
        "calico"
        "cilium"
      ];
      default = "flannel";
      description = "The CNI plugin to use for networking";
    };
    nodes = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            type = mkOption {
              type = types.enum [
                "master"
                "worker"
              ];
              description = "The type of the Kubernetes node (master or worker)";
            };
            ip = mkOption {
              type = types.str;
              description = "The IP address of the node";
            };
            hostname = mkOption {
              type = types.str;
              description = "The hostname of the node";
            };
            extraConfig = mkOption {
              type = types.attrs;
              default = { };
              description = "Extra configuration options for the node";
            };
          };
        }
      );
      default = { };
      description = "The nodes in the Kubernetes cluster";
    };
    extraMasterConfig = mkOption {
      type = types.attrs;
      default = { };
      description = "Extra configuration options for master nodes";
    };
    extraWorkerConfig = mkOption {
      type = types.attrs;
      default = { };
      description = "Extra configuration options for worker nodes";
    };
  };
}
