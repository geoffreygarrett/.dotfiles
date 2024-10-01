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
}
