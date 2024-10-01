{ ... }:

{
  imports = [
    ./shared.nix
  ];

  services.k3s = {
    role = "agent";
    serverAddr = "https://mariner-1.nixus.net:6443";
  };
}
