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
in
{
  imports = [ sharedModule ];

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      kubectl
      kubernetes-helm
    ];

    # Darwin-specific configuration (e.g., for development environments)
    launchd.user.agents.kubeconfig = {
      serviceConfig = {
        ProgramArguments = [
          "${pkgs.writeScript "generate-kubeconfig" ''
            #!${pkgs.stdenv.shell}
            ${pkgs.kubectl}/bin/kubectl config view --raw > ~/.kube/config
          ''}"
        ];
        RunAtLoad = true;
        StandardOutPath = "/tmp/kubeconfig-gen.log";
        StandardErrorPath = "/tmp/kubeconfig-gen.error.log";
      };
    };

    # You might want to add more Darwin-specific Kubernetes configurations here
  };
}
