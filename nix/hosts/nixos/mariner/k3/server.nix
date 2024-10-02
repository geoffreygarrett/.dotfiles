{ ... }:
{
  imports = [
    ./shared.nix
  ];
  services.k3s = {
    enable = true;
    role = "server";
    clusterInit = true;
    extraFlags = [
      # "--cluster-init"
      # "--kube-controller-manager-arg=node-monitor-period=5s"
      # "--kube-controller-manager-arg=node-monitor-grace-period=20s"
      # "--kube-controller-manager-arg=pod-eviction-timeout=30s"
      # "--kube-controller-manager-arg=controllers=*,bootstrapsigner,tokencleaner,node-controller"
    ];
  };

  # open required ports for k3s
  networking.firewall.allowedTCPPorts = [
    8001
  ];
}
