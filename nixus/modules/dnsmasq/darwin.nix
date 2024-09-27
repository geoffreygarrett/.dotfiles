{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.nixus.dnsmasq;
  sharedModule = import ./shared.nix { inherit lib; };

  hostEntries = concatStrings (
    mapAttrsToList (
      hostname: host:
      concatMapStrings (address: ''
        address=/${hostname}/${address}
      '') host.addresses
    ) cfg.hosts
  );

  fullConfig = ''
    ${hostEntries}
    ${cfg.extraConfig}
  '';
in
{
  imports = [ sharedModule ];

  config = mkIf cfg.enable {
    services.dnsmasq = {
      enable = mkDefault true;
      addresses = cfg.hosts;
    };

    launchd.daemons.dnsmasq.serviceConfig.ProgramArguments = mkIf config.services.dnsmasq.enable [
      "${pkgs.dnsmasq}/bin/dnsmasq"
      "--keep-in-foreground"
      "--conf-file=${pkgs.writeText "dnsmasq.conf" fullConfig}"
    ];
  };
}
