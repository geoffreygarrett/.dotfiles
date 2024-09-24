{
  self,
  config,
  user,
  keys,
  inputs,
  ...
}:
let
  hostname = "mariner-1";
in
{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-3
    ../../../modules/nixos/tailscale.nix
    ../../../modules/nixos/samba.nix
    ../shared.nix
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];
  system.stateVersion = "22.05";
  sdImage.compressImage = false;
  sops = {
    defaultSopsFile = "${self}/secrets/default.yaml";
    secrets."wireless.env" = { };
  };

  # Networking 
  networking = {
    hostName = hostname;
    wireless = {
      enable = true;
      secretsFile = config.sops.secrets."wireless.env".path;
      networks = {
        "Haemanthus" = {
          pskRaw = "ext:haemanthus_psk";
        };
      };
    };
  };

  # Enable SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  # Create a user
  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "changeme";
    openssh.authorizedKeys.keys = keys;
  };

  # Allow the user to use sudo without a password (optional, remove if not needed)
  security.sudo.wheelNeedsPassword = false;

  # Firewall configuration
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };
}
