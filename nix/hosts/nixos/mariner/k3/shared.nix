{
  keys,
  config,
  ...
}:
{
  # Enable K3s service
  services.k3s.enable = true;

  # k3s token from default for now
  sops.secrets.k3s-token = { };
  services.k3s.tokenFile = config.sops.secrets.k3s-token.path;

  # Open required ports for K3s
  networking.firewall.allowedTCPPorts = [ 6443 ];
  networking.firewall.allowedUDPPorts = [ 8472 ];

  # Enable IP forwarding (required for K3s networking)
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # Add any other common configurations here
  # For example, SSH settings, user configurations, etc.
  services.openssh.enable = true;
  users.users.k3s = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = keys;
  };
}
