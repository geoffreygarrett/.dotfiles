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
  # Common k3s configuration
  k3sConfig = {
    enable = true;
    role = if config.networking.hostName == "mariner-3" then "server" else "agent";
    token = "<randomized common secret>"; # Replace with actual shared token
    clusterInit = if config.networking.hostName == "mariner-3" then true else false; # Initialize only on master node
    serverAddr = lib.mkIf (
      config.networking.hostName == "mariner-4"
    ) "https://mariner-3.nixus.net:6443";
    extraFlags = if config.networking.hostName == "mariner-3" then [ "--no-deploy traefik" ] else [ ];
  };
in
{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-3
    inputs.sops-nix.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    ./kubernetes.nix
    # impermanence.nixosModules.impermanence
    ../../../modules/shared/secrets.nix
    ../../../modules/nixos/tailscale.nix
    ../../../modules/nixos/openssh.nix
    ../../../modules/nixos/samba.nix
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ] ++ extraModules;

  system.stateVersion = "24.11";
  sdImage.compressImage = false;

  # K3s installation and configuration
  # services.k3s = k3sConfig;

  # Network and firewall configuration
  networking = {
    hostName = hostname;
    useDHCP = false;
    dhcpcd.wait = "background";
    interfaces.wlan0.useDHCP = true;
    wireless = {
      enable = true;
      userControlled.enable = true;
      secretsFile = config.sops.secrets.wireless_secrets.path;
      networks = {
        "Haemanthus" = {
          priority = 90;
          pskRaw = "ext:haemanthus_psk";
        };
      };
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # SSH
        80 # HTTP
        443 # HTTPS
        6443 # k3s: Kubernetes API server
        10250 # Kubelet API
      ];
      allowedUDPPorts = [
        # 8472  # Required if using Flannel in multi-node setup
      ];
    };
  };

  # User configuration
  users.users.${user} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    initialPassword = "changeme";
    openssh.authorizedKeys.keys = keys;
  };
  users.users.root.openssh.authorizedKeys.keys = keys;
  programs.zsh.enable = true;

  # Sudo configuration
  security.sudo.wheelNeedsPassword = false;

  # SOPS secrets management
  sops = {
    defaultSopsFile = "${self}/secrets/default.yaml";
    secrets.wireless_secrets = { };
    secrets."users/${user}/password" = { };
  };

  # Trusted public keys for Nix
  nix.settings = {
    trusted-public-keys = [
      "builder-name:4w+NIGfO2WFJ6xKs4JaPoiUcxjm4YDG8ycLt3M67uBA=%"
    ];
  };
}
