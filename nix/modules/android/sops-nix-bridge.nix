# sops-nix-bridge.nix
{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.nix-on-droid.sops = with lib; {
    secrets = mkOption {
      type = types.attrs;
      default = { };
      description = "Secrets configuration passed from Home Manager";
    };
    defaultSecretsMountPoint = mkOption {
      type = types.str;
      default = "/data/data/com.termux.nix/files/home/.run/secrets";
      description = "Default mount point for secrets";
    };
    defaultSymlinkPath = mkOption {
      type = types.str;
      default = "${config.user.home}/.local/share/sops-nix";
      description = "Default symlink path for secrets";
    };
    age = {
      keyFile = mkOption {
        type = types.str;
        default = "/data/data/com.termux.nix/files/home/.config/sops/age/keys.txt";
        description = "Path to the age key file";
      };
      generateKey = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to generate the age key";
      };
    };
  };

  config =
    let
      cfg = config.nix-on-droid.sops;
      sops-install-secrets = pkgs.sops-install-secrets;
      manifest = pkgs.writeTextFile {
        name = "manifest.json";
        text = builtins.toJSON {
          secrets = builtins.attrValues cfg.secrets;
          secretsMountPoint = cfg.defaultSecretsMountPoint;
          symlinkPath = cfg.defaultSymlinkPath;
        };
      };
      script = pkgs.writeShellScript "sops-nix-user" ''
        ${lib.optionalString cfg.age.generateKey ''
          if [[ ! -f ${lib.escapeShellArg cfg.age.keyFile} ]]; then
            echo "Generating machine-specific age key..."
            ${pkgs.coreutils}/bin/mkdir -p $(${pkgs.coreutils}/bin/dirname ${lib.escapeShellArg cfg.age.keyFile})
            ${pkgs.age}/bin/age-keygen -o ${lib.escapeShellArg cfg.age.keyFile}
          fi
        ''}
        ${sops-install-secrets}/bin/sops-install-secrets -ignore-passwd ${manifest}
      '';
    in
    {
      build.activation.sops-nix = lib.mkIf (cfg.secrets != { }) ''
        $VERBOSE_ECHO "Setting up sops-nix for Nix-on-Droid..."
        ${script}
      '';

      environment.packages = lib.mkIf (cfg.secrets != { }) [
        (pkgs.writeScriptBin "sops-nix-run" ''
          #!${pkgs.runtimeShell}
          echo "Running sops-nix manually..."
          ${script}
        '')
      ];
    };
}
