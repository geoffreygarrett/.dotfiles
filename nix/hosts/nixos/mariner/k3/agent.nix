{ ... }:

{
  imports = [
    ./shared.nix
  ];

  services.k3s = {
    role = "agent";
    serverAddr = "https://mariner-1.nixus.net:6443";
    tokenFile = "/var/lib/rancher/k3s/agent/node-token";
  };
}
