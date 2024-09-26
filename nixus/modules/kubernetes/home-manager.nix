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

  generateKubeconfig = cfg: ''
    apiVersion: v1
    clusters:
    - cluster:
        server: https://${head (filter (n: n.type == "master") (attrValues cfg.nodes)).ip}:6443
      name: ${cfg.clusterName}
    contexts:
    - context:
        cluster: ${cfg.clusterName}
        user: ${cfg.clusterName}-admin
      name: ${cfg.clusterName}
    current-context: ${cfg.clusterName}
    kind: Config
    users:
    - name: ${cfg.clusterName}-admin
      user:
        client-certificate-data: # Add base64 encoded client certificate data here
        client-key-data: # Add base64 encoded client key data here
  '';

in
{
  imports = [ sharedModule ];

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      kubectl
      kubernetes-helm
    ];

    home.file.".kube/config".text = generateKubeconfig cfg;

    programs.zsh = {
      enable = true;
      shellAliases = {
        k = "kubectl";
        kgp = "kubectl get pods";
        kgs = "kubectl get services";
        kgn = "kubectl get nodes";
        kdp = "kubectl describe pod";
        kds = "kubectl describe service";
        kdn = "kubectl describe node";
      };
    };

    programs.bash = {
      enable = true;
      shellAliases = {
        k = "kubectl";
        kgp = "kubectl get pods";
        kgs = "kubectl get services";
        kgn = "kubectl get nodes";
        kdp = "kubectl describe pod";
        kds = "kubectl describe service";
        kdn = "kubectl describe node";
      };
    };

  };
}
