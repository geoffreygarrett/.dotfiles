{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.sops-nix;
in
{
  options.services.sops-nix = {
    enable = mkEnableOption "sops-nix secret management";

    secrets = mkOption {
      type = types.attrs;
      default = { };
      description = "Secrets to manage with sops-nix";
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

  config = mkIf cfg.enable {
    environment.packages = with pkgs; [
      sops
      age
    ];

    build.activation.sops-nix =
      let
        sops-install-secrets = pkgs.sops-install-secrets;
        manifest = pkgs.writeTextFile {
          name = "manifest.json";
          text = builtins.toJSON {
            secrets = builtins.attrValues cfg.secrets;
            secretsMountPoint = cfg.defaultSecretsMountPoint;
            symlinkPath = cfg.defaultSymlinkPath;
          };
        };
      in
      ''
        $VERBOSE_ECHO "Setting up sops-nix for Nix-on-Droid..."
        ${optionalString cfg.age.generateKey ''
          if [[ ! -f ${escapeShellArg cfg.age.keyFile} ]]; then
            echo "Generating machine-specific age key..."
            ${pkgs.coreutils}/bin/mkdir -p $(${pkgs.coreutils}/bin/dirname ${escapeShellArg cfg.age.keyFile})
            ${pkgs.age}/bin/age-keygen -o ${escapeShellArg cfg.age.keyFile}
          fi
        ''}
        ${sops-install-secrets}/bin/sops-install-secrets -ignore-passwd ${manifest}
      '';

    environment.packages = [
      (pkgs.writeScriptBin "sops-nix-run" ''
        #!${pkgs.runtimeShell}
        echo "Running sops-nix manually..."
        ${config.build.activation.sops-nix}
      '')
    ];
  };
}
