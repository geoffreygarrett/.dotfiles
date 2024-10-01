{
  keys,
  ...
}:
{
  # Enable K3s service
  services.k3s.enable = true;

  # k3s token secret
  sops.secrets.k3s-token = { };

  # Open required ports for K3s
  networking.firewall.allowedTCPPorts = [
    6443
    10250
  ];
  networking.firewall.allowedUDPPorts = [ 8472 ];

  # Enable IP forwarding (required for K3s networking)
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # SSH settings
  services.openssh.enable = true;

  # User configurations
  users.users.k3s = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = keys;
  };

  # Ensure correct permissions for k3s
  systemd.services.k3s.serviceConfig = {
    SupplementaryGroups = [ "keys" ];
  };
}
