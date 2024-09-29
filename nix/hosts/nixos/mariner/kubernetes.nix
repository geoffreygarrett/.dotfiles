{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.mariner-k3s;
in
{
  options.services.mariner-k3s = with lib; {
    enable = mkEnableOption "Mariner K3s Cluster";
    nodeType = mkOption {
      type = types.enum [
        "server"
        "agent"
      ];
      description = "The role of this node in the K3s cluster";
    };
    serverAddr = mkOption {
      type = types.str;
      description = "The address of the K3s server (for agent nodes)";
      default = "";
    };
    extraFlags = mkOption {
      type = types.listOf types.str;
      description = "Additional flags to pass to K3s";
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    # K3s configuration
    services.k3s = {
      enable = true;
      role = cfg.nodeType;
      tokenFile = config.sops.secrets.k3s-token.path;
      serverAddr = lib.mkIf (cfg.nodeType == "agent") cfg.serverAddr;
      extraFlags = cfg.extraFlags;
    };

    # Sops configuration
    sops.secrets.k3s-token = { };

    # Networking configuration
    networking = {
      firewall = {
        enable = true;
        allowedTCPPorts = [
          22
          80
          443
          10250
        ] ++ lib.optionals (cfg.nodeType == "server") [ 6443 ];
        allowedUDPPorts = [ 8472 ]; # Flannel VXLAN
      };
    };

    # Container and virtualization configuration
    virtualisation = {
      containerd.enable = true;
      containers = {
        enable = true;
        containersConf.cniPlugins = with pkgs; [ cni-plugins ];
      };
      docker.enable = lib.mkForce false;
    };

    # System packages
    environment.systemPackages = with pkgs; [
      kubectl
      kubernetes-helm
      k9s
      etcd
      cri-tools
      sops
    ];

    # Monitoring and logging
    services.prometheus = {
      enable = true;
      exporters.node = {
        enable = true;
        enabledCollectors = [
          "systemd"
          "processes"
          "filesystem"
          "netdev"
        ];
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
  };
}
