{ config, lib, ... }:

with lib;

let
  cfg = config.nixus.dnsmasq;
  hostEntries = concatStrings (
    mapAttrsToList (
      hostname: host: concatMapStrings (addr: "${addr.ip} ${hostname}\n") host.addresses
    ) cfg.hosts
  );
  sharedModule = import ./shared.nix { inherit lib; };

in
{
  imports = [ sharedModule ];
  config = mkIf cfg.enable {
    # systemd.services.dnsmasq = {
    #   after = [ "network-online.target" ];
    #   wants = [ "network-online.target" ];
    # };
    services.dnsmasq = {
      enable = true;
      settings = mkMerge [
        {
          domain-needed = true;
          bogus-priv = true;
          expand-hosts = true;
          domain = "nixus.net";
          local = "/nixus.net/";
        }
        cfg.settings
        {
          addn-hosts = [ "/etc/nixus-dnsmasq-hosts.conf" ];
          address = flatten (
            mapAttrsToList (hostname: host: map (addr: "/${hostname}/${addr.ip}") host.addresses) cfg.hosts
          );
        }
      ];
    };
    environment.etc."nixus-dnsmasq-hosts.conf".text = hostEntries;
  };
}
# TODO: dnssec needs root anchor, figure out if we want to include this configuration (needs research)
