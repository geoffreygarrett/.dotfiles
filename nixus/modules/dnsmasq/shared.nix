{ lib, ... }:

with lib;

{
  options.nixus.dnsmasq = {
    enable = mkEnableOption "Nixus dnsmasq module";
    hosts = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            addresses = mkOption {
              type = types.listOf (
                types.submodule {
                  options = {
                    ip = mkOption {
                      type = types.str;
                      description = "IP address for the host";
                    };
                    type = mkOption {
                      type = types.enum [
                        "local"
                        "tailscale"
                      ];
                      description = "Type of the address";
                    };
                  };
                }
              );
              description = "List of IP addresses for the host";
            };
          };
        }
      );
      default = { };
      description = "Attribute set of hosts to be resolved";
    };
    settings = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = "Additional dnsmasq settings";
    };
  };
}
