{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.nixus.kubernetes;
  sharedModule = import ./shared.nix { inherit lib pkgs; };
  getMasterNode = nodes: head (filter (n: n.type == "master") (attrValues nodes));
  getNodeConfig =
    nodes: hostName: nodes.${hostName} or (throw "No configuration found for host ${hostName}");

  icons =
    if cfg.useNerdFonts then
      {
        header = "===";
        warning = " ";
        info = " ";
        success = " ";
      }
    else
      {
        header = "===";
        warning = "⚠️ ";
        info = "ℹ️ ";
        success = "✅";
      };

  formatHeader = text: ''
    echo ""
    echo "${icons.header} ${text} ${icons.header}"
    echo ""
  '';

  formatWarning = text: ''
    echo "${icons.warning} ${text}" >&2
  '';

  formatInfo = text: ''
    echo "${icons.info} ${text}"
  '';

  formatSuccess = text: ''
    echo "${icons.success} ${text}"
  '';

in
{
  imports = [ sharedModule ];

  options.nixus.kubernetes = {
    useNerdFonts = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc "Use Nerd Fonts icons instead of emojis for formatting output.";
    };
    firewall = {
      enableAPIServer = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc "Open firewall for Kubernetes API server. Opens TCP port 6443.";
      };
      enableKubelet = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc "Open firewall for Kubelet. Opens TCP port 10250.";
      };
      enableNodePorts = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc "Open firewall for NodePort services. Opens TCP ports 30000-32767.";
      };
      acknowledgeFirewallRisks = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc "Acknowledge understanding of the firewall risks and silence warnings.";
      };
    };
  };

  config = mkIf cfg.enable {
    services.kubernetes = mkMerge [
      {
        roles = [
          "master"
          "node"
        ];
        masterAddress = (getMasterNode cfg.nodes).ip;
        easyCerts = true;
        apiserver = {
          securePort = 6443;
          advertiseAddress = (getNodeConfig cfg.nodes config.networking.hostName).ip;
        };
        addons.dns.enable = true;
        flannel.enable = cfg.cniPlugin == "flannel";
        calico.enable = cfg.cniPlugin == "calico";
        kubelet.extraOpts = "--node-ip=${(getNodeConfig cfg.nodes config.networking.hostName).ip}";
      }
      (mkIf ((getNodeConfig cfg.nodes config.networking.hostName).type == "master") (
        {
          apiserver.extraOpts = "--service-cluster-ip-range=${cfg.serviceNetworkCidr}";
          controllerManager.extraOpts = "--cluster-cidr=${cfg.podNetworkCidr} --service-cluster-ip-range=${cfg.serviceNetworkCidr}";
        }
        // cfg.extraMasterConfig
      ))
      (mkIf ((getNodeConfig cfg.nodes config.networking.hostName).type == "worker") (
        {
          # Worker-specific configuration
        }
        // cfg.extraWorkerConfig
      ))
      (getNodeConfig cfg.nodes config.networking.hostName).extraConfig
    ];

    networking = {
      inherit (getNodeConfig cfg.nodes config.networking.hostName) hostname;
      extraHosts = concatStringsSep "\n" (
        mapAttrsToList (name: node: "${node.ip} ${node.hostname}") cfg.nodes
      );
      firewall = {
        allowedTCPPorts =
          (optional cfg.firewall.enableAPIServer 6443)
          ++ (optional cfg.firewall.enableKubelet 10250)
          ++ (optionals cfg.firewall.enableNodePorts (range 30000 32767));
      };
    };

    environment.systemPackages = with pkgs; [
      kubectl
      kubernetes
    ];

    warnings = mkIf (!cfg.firewall.acknowledgeFirewallRisks) [
      (mkIf cfg.firewall.enableAPIServer ''
        Kubernetes: TCP port 6443 has been opened for the Kubernetes API server.
        This allows external access to your cluster's control plane.
        If this was unintentional, please disable this feature by setting nixus.kubernetes.firewall.enableAPIServer = false;
        Otherwise, ensure proper authentication and authorization mechanisms are in place to secure your cluster.
      '')
      (mkIf cfg.firewall.enableKubelet ''
        Kubernetes: TCP port 10250 has been opened for the Kubelet.
        This allows direct access to node-level APIs, which could be a security risk if not properly secured.
        If this was unintentional, please disable this feature by setting nixus.kubernetes.firewall.enableKubelet = false;
        Otherwise, ensure that proper authentication and authorization are configured for Kubelet access.
      '')
      (mkIf cfg.firewall.enableNodePorts ''
        Kubernetes: TCP ports 30000-32767 have been opened for NodePort services.
        This allows external access to services of type NodePort, which could expose your applications to the internet.
        If this was unintentional, please disable this feature by setting nixus.kubernetes.firewall.enableNodePorts = false;
        Otherwise, ensure that you are aware of which services are exposed via NodePorts and that they are properly secured.
      '')
    ];

    system.activationScripts.kubernetesFirewallInfo = ''
      ${formatHeader "Kubernetes Firewall Configuration"}

      ${formatInfo "Enabled Features:"}
      ${optionalString cfg.firewall.enableAPIServer (formatInfo "  • API Server: TCP port 6443 is open")}
      ${optionalString cfg.firewall.enableKubelet (formatInfo "  • Kubelet: TCP port 10250 is open")}
      ${optionalString cfg.firewall.enableNodePorts (
        formatInfo "  • NodePorts: TCP ports 30000-32767 are open"
      )}

      ${
        if cfg.firewall.acknowledgeFirewallRisks then
          ''
            ${formatSuccess "Firewall risks have been acknowledged. Warnings are silenced."}
          ''
        else
          ''
            ${formatWarning "Security Notices:"}
            ${formatWarning "  • Ensure these ports are only accessible on trusted networks."}
            ${formatWarning "  • If any of these features were enabled unintentionally, please disable them in your configuration."}
            ${formatWarning "  • To acknowledge these risks and silence warnings, set nixus.kubernetes.firewall.acknowledgeFirewallRisks = true;"}
          ''
      }

      ${formatHeader "End of Kubernetes Firewall Configuration"}
    '';

    assertions = [
      {
        assertion =
          cfg.firewall.enableAPIServer || cfg.firewall.enableKubelet || cfg.firewall.enableNodePorts;
        message = "At least one firewall option should be enabled for Kubernetes to function properly.";
      }
    ];
  };
}
