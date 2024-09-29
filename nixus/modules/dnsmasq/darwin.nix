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

  formatAddresses = addresses: concatMapStrings (addr: "${addr.ip} ") addresses;

  hostEntries = concatStrings (
    mapAttrsToList (hostname: host: "${formatAddresses host.addresses}${hostname}\n") cfg.hosts
  );

  dnsmasqConf = ''
    ${concatStringsSep "\n" (mapAttrsToList (n: v: "${n}=${toString v}") cfg.settings)}
    ${hostEntries}
    addn-hosts=${pkgs.writeText "nixus-dnsmasq-hosts.conf" hostEntries}
    ${concatMapStrings (
      hostname:
      concatMapStrings (addr: "address=/${hostname}/${addr.ip}\n") cfg.hosts.${hostname}.addresses
    ) (attrNames cfg.hosts)}
    ${cfg.extraConfig}
    log-queries
    log-facility=/var/log/dnsmasq.log
  '';

  formattedAddresses = mapAttrs (
    hostname: host: concatMapStrings (addr: "/${hostname}/${addr.ip}") host.addresses
  ) cfg.hosts;

in
{
  imports = [ sharedModule ];

  options.nixus.dnsmasq = {
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Additional configuration for dnsmasq";
    };
    debugMode = mkEnableOption "Enable debug mode for DNSMasq";
  };

  config = mkIf cfg.enable {
    services.dnsmasq = {
      enable = true;
      addresses = formattedAddresses;
    };

    launchd.daemons.dnsmasq = {
      serviceConfig = {
        ProgramArguments = [
          "${pkgs.dnsmasq}/bin/dnsmasq"
          "--keep-in-foreground"
          "--conf-file=${pkgs.writeText "dnsmasq.conf" dnsmasqConf}"
        ] ++ optionals cfg.debugMode [ "--log-debug" ];
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "/var/log/dnsmasq.log";
        StandardErrorPath = "/var/log/dnsmasq.log";
      };
    };

    environment.etc."dnsmasq.conf".source = pkgs.writeText "dnsmasq.conf" dnsmasqConf;

    system.activationScripts.postActivation.text = ''
      # Ensure DNSMasq is used for DNS resolution
      /usr/sbin/networksetup -setdnsservers Wi-Fi 127.0.0.1
      ${pkgs.dnsmasq}/bin/dnsmasq --test
      /usr/bin/dscacheutil -flushcache
      /usr/bin/killall -HUP mDNSResponder
    '';

    environment.systemPackages = [ pkgs.dnsmasq ];
  };
}
