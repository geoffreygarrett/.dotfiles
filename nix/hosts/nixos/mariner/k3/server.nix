{ config, pkgs, ... }:

{
  imports = [
    ./shared.nix
  ];

  services.k3s = {
    role = "server";
    extraFlags = [
      "--cluster-init"
    ];
  };

}
