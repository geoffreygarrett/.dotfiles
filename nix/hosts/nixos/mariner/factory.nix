{
  self,
  inputs,
  pkgs,
  ...
}:
# Factory function
{
  hostname,
  user,
  keys,
  extraModules ? [ ],
}:
{ config, lib, ... }:
let
in
# kubernetesClusterConfig = (import ./kubernetes-cluster.nix { inherit lib; }).kubernetes-cluster;
{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-3
    inputs.sops-nix.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    ../../../modules/shared/secrets.nix
    ../../../modules/nixos/tailscale.nix
    ../../../modules/nixos/openssh.nix
    ../../../modules/nixos/samba.nix
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ] ++ extraModules;

  system.stateVersion = "24.11";
  sdImage.compressImage = false;

  # nixus.kubernetes = {
  #   enable = true;
  #   inherit (kubernetesClusterConfig)
  #     clusterName
  #     podNetworkCidr
  #     serviceNetworkCidr
  #     cniPlugin
  #     ;
  #   nodes = kubernetesClusterConfig.nodes;
  #   firewall = {
  #     enableAPIServer = kubernetesClusterConfig.nodes.${hostname}.type == "master";
  #     enableKubelet = true;
  #     enableNodePorts = true;
  #     acknowledgeFirewallRisks = true;
  #   };
  # };

  sops = {
    defaultSopsFile = "${self}/secrets/default.yaml";
    secrets.wireless_secrets = { };
    secrets."users/${user}/password" = { };
    templates."secrets-file" = {
      path = "/etc/networks/secrets-file";
      content = ''
        ${config.sops.placeholder.wireless_secrets}
      '';
    };
  };

  # Network configuration
  networking = {
    hostName = hostname;
    useDHCP = false;
    dhcpcd.wait = "background";
    interfaces.wlan0.useDHCP = true;
    wireless = {
      enable = true;
      userControlled.enable = true;
      secretsFile = config.sops.templates."secrets-file".path;
    };
  };

  # Docker virtualisation 
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  # Create a user
  users.users.${user} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    initialPassword = "changeme";
    openssh.authorizedKeys.keys = keys;
  };
  users.users.root.openssh.authorizedKeys.keys = keys;
  programs.zsh.enable = true;

  # Allow the user to use sudo without a password (optional, remove if not needed)
  security.sudo.wheelNeedsPassword = false;

  # Firewall configuration
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22 # SSH
      80 # HTTP
      443 # HTTPS
      4070 # Spotify
      5353 # mDNS (for device discovery)
    ];
  };
}
