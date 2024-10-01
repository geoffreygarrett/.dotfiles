{ config, ... }:
{
  imports = [
    ./shared.nix
  ];
  services.k3s = {
    enable = true;
    role = "agent";
    serverAddr = "https://mariner-1.nixus.net:6443";
    tokenFile = config.sops.secrets.k3s-token.path;
  };
}
