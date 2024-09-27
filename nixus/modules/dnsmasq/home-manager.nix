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
    home.packages = [ pkgs.dnsmasq ];

    xdg.configFile."dnsmasq/dnsmasq.conf".text = fullConfig;

    systemd.user.services.dnsmasq = {
      Unit = {
        Description = "Dnsmasq DNS server";
        After = [ "network.target" ];
      };
      Service = {
        ExecStart = "${pkgs.dnsmasq}/bin/dnsmasq --keep-in-foreground --conf-file=%h/.config/dnsmasq/dnsmasq.conf";
        Restart = "always";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
