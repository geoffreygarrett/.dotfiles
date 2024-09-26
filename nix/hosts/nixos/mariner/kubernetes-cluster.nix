{ lib, ... }:
{
  kubernetes-cluster = {
    clusterName = "rpi-cluster";
    podNetworkCidr = "10.244.0.0/16";
    serviceNetworkCidr = "10.96.0.0/12";
    cniPlugin = "flannel";
    nodes = {
      mariner-1 = {
        type = "master";
        ip = "192.168.1.101";
        hostname = "mariner-1";
      };
      mariner-2 = {
        type = "worker";
        ip = "192.168.1.102";
        hostname = "mariner-2";
      };
      # Add more nodes here as needed
    };
  };
}
