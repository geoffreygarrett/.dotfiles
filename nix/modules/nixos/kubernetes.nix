{
  config,
  lib,
  pkgs,
  ...
}:

let
  nodeType = config.networking.hostName;
  isEdgeNode = nodeType == "edge-node";
  isCoreNode = nodeType == "core-node";

  sharedPorts = [ 10250 ];
  corePorts = [ 6443 ] ++ sharedPorts;
in
{

  # Sops configuration
  sops = {
    secrets.k3s-token = { };
  };

  # Cluster configuration
  services = {
    k3s = lib.mkIf isEdgeNode {
      enable = true;
      role = "agent";
      serverAddr = "https://core-node:6443";
      tokenFile = config.sops.secrets.k3sToken.path;
      extraFlags = [
        "--node-label=node.kubernetes.io/type=edge"
        "--kubelet-arg=eviction-hard=memory.available<100Mi,nodefs.available<10%"
      ];
    };

    kubernetes = lib.mkIf isCoreNode {
      roles = [
        "master"
        "node"
      ];
      masterAddress = "${nodeType}.cluster.local";
      easyCerts = true;
      apiserver = {
        enable = true;
        extraOpts = "--allow-privileged=true --feature-gates=PodSecurity=true";
      };
      addons.dns.enable = true;
      addons.dashboard.enable = true;
    };
  };

  # Shared container and virtualization configuration
  virtualisation = {
    containerd.enable = true;
    containers = {
      enable = true;
      containersConf.cniPlugins = with pkgs; [ cni-plugins ];
    };
    docker.enable = lib.mkForce false;
  };

  # Networking configuration
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = if isCoreNode then corePorts else sharedPorts;
      allowedUDPPorts = [ 8472 ]; # Flannel VXLAN
    };
    extraCommands = lib.mkIf config.services.kubernetes.addons.flannel.enable ''
      ip route add 10.244.0.0/16 dev flannel.1 scope link
    '';
  };

  # Cluster management tools
  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes-helm
    k9s
    etcd
    cri-tools
    sops # Include sops CLI tool
  ];

  # Monitoring and logging
  services = {
    prometheus = {
      enable = true;
      exporters = {
        node = {
          enable = true;
          enabledCollectors = [
            "systemd"
            "processes"
            "filesystem"
            "netdev"
          ];
        };
      };
    };
    grafana = {
      enable = true;
      provision = {
        enable = true;
        datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://localhost:9090";
          }
        ];
      };
    };
  };

  # Example application deployment
  services.nginx = {
    enable = true;
    virtualHosts."example.com" = {
      locations."/" = {
        proxyPass =
          if isEdgeNode then
            "http://localhost:8080" # K3s service
          else
            "http://app-service.default.svc.cluster.local"; # Kubernetes service
      };
    };
  };

  # System optimizations
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.bridge.bridge-nf-call-iptables" = 1;
  };

  # Security enhancements
  security = {
    audit.enable = true;
    auditd.enable = true;
    apparmor.enable = true;
  };
}
