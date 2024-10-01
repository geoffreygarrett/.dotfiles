{ ... }:
{
  imports = [
    ./shared.nix
  ];
  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = [
      "--cluster-init"
    ];
  };

  # open required ports for k3s
  networking.firewall.allowedTCPPorts = [
    8001
  ];
}
