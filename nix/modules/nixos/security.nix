# File: modules/security-level.nix

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  levels = [
    "low"
    "medium"
    "high"
    "paranoid"
  ];

  # Function to generate configurations based on the security level
  levelConfigurations =
    {
      username ? null,
    }:
    rec {
      low = {
        #### Low Security Settings ####
        security.sudo.enable = true;
        security.sudo.wheelNeedsPassword = false;
        services.openssh.enable = true;
        services.openssh.settings.PermitRootLogin = "yes";
      };

      medium = {
        #### Medium Security Settings ####
        security.sudo.enable = true;
        security.sudo.wheelNeedsPassword = true;
        services.openssh.enable = true;
        services.openssh.settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = true;
        };
      };

      high = {
        #### High Security Settings ####
        security.sudo.enable = true;
        security.sudo.wheelNeedsPassword = true;
        boot.kernelParams = [
          "page_poison=1"
          "slab_nomerge"
          "slub_debug=FZP"
        ];
        boot.kernel.sysctl = {
          "kernel.kptr_restrict" = 2;
          "kernel.dmesg_restrict" = 1;
          "net.core.bpf_jit_harden" = 2;
          "kernel.unprivileged_bpf_disabled" = 1;
        };
        services.openssh.enable = true;
        services.openssh.settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
      };

      paranoid =
        let
          # Ensure username is provided
          _username =
            if username != null then
              username
            else
              throw "security.username must be set for security.level = 'paranoid'";
        in
        {
          #### Paranoid Security Settings ####
          # Replace sudo with doas
          security.sudo.enable = false;
          security.doas = {
            enable = true;
            extraRules = [
              {
                users = [ _username ];
                keepEnv = true;
                persist = true;
              }
            ];
          };
          # Enable auditd and AppArmor
          security.auditd.enable = true;
          security.apparmor = {
            enable = true;
            killUnconfinedConfinables = true;
          };
          # Secure boot settings
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;
          boot.kernelParams = [
            "page_poison=1"
            "slab_nomerge"
            "slub_debug=FZP"
          ];
          boot.kernel.sysctl = {
            "kernel.kptr_restrict" = 2;
            "kernel.dmesg_restrict" = 1;
            "net.core.bpf_jit_harden" = 2;
            "kernel.unprivileged_bpf_disabled" = 1;
            "net.ipv4.conf.all.log_martians" = 1;
            "net.ipv4.conf.default.log_martians" = 1;
          };
          # Firewall configurations
          networking.firewall = {
            enable = true;
            allowedTCPPorts = [ ]; # No open ports by default
            allowPing = false;
            logReversePathDrops = true;
          };
          networking.nftables.enable = true;
          # SSH configurations
          services.openssh.enable = true;
          services.openssh.settings = {
            PermitRootLogin = "no";
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
            X11Forwarding = false;
          };
          services.openssh.extraConfig = ''
            AllowUsers ${_username}
            AuthenticationMethods publickey
          '';
          # System hardening
          systemd = {
            coredump.enable = false;
            services.systemd-random-seed.enable = true;
          };
          # Enforce read-only /home
          fileSystems."/home" = mkIf (config.fileSystems ? "/home") {
            options = [
              "noexec"
              "nosuid"
              "nodev"
            ];
          };
        };
    };
in
{
  options = {
    security = {
      level = mkOption {
        type = types.enum levels;
        default = "medium";
        description = ''
          Sets the system security level. Possible values are:
          - "low": Minimal security settings.
          - "medium": Reasonable security defaults.
          - "high": Enhanced security settings.
          - "paranoid": Maximum security hardening.
        '';
      };

      username = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          The username used in security configurations where necessary (e.g., for doas rules).
          **Required** when `security.level` is set to "paranoid".
        '';
      };

      customConfigurations = mkOption {
        type = types.attrsOf types.anything;
        default = { };
        description = ''
          Custom security configurations to be merged into the selected level.
          This allows for overriding or extending the predefined settings.
        '';
      };
    };
  };

  config =
    let
      # Retrieve the selected level's configuration
      levelConfig =
        (levelConfigurations { username = config.security.username; }).${config.security.level} or { };

    in
    mkMerge [
      levelConfig
      config.security.customConfigurations
    ];
}
