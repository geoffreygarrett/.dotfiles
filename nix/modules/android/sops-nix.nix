{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.services.sops-nix;
  sops-install-secrets = (pkgs.callPackage ../.. { }).sops-install-secrets;

  secretType = types.submodule (
    { config, name, ... }:
    {
      options = {
        name = mkOption {
          type = types.str;
          default = name;
          description = "Name of the file used in /run/user/*/secrets";
        };
        key = mkOption {
          type = types.str;
          default = name;
          description = "Key used to lookup in the sops file.";
        };
        path = mkOption {
          type = types.str;
          default = "${cfg.defaultSymlinkPath}/${name}";
          description = "Path where secrets are symlinked to.";
        };
        format = mkOption {
          type = types.enum [
            "yaml"
            "json"
            "binary"
            "ini"
            "dotenv"
          ];
          default = cfg.defaultSopsFormat;
          description = "File format used to decrypt the sops secret.";
        };
        mode = mkOption {
          type = types.str;
          default = "0400";
          description = "Permissions mode in octal.";
        };
        sopsFile = mkOption {
          type = types.path;
          default = cfg.defaultSopsFile;
          description = "Sops file the secret is loaded from.";
        };
      };
    }
  );

  manifestFor =
    suffix: secrets:
    pkgs.writeTextFile {
      name = "manifest${suffix}.json";
      text = builtins.toJSON {
        secrets = builtins.attrValues secrets;
        secretsMountPoint = cfg.defaultSecretsMountPoint;
        symlinkPath = cfg.defaultSymlinkPath;
        keepGenerations = cfg.keepGenerations;
        gnupgHome = cfg.gnupg.home;
        sshKeyPaths = cfg.gnupg.sshKeyPaths;
        ageKeyFile = cfg.age.keyFile;
        ageSshKeyPaths = cfg.age.sshKeyPaths;
        userMode = true;
        logging = {
          keyImport = builtins.elem "keyImport" cfg.log;
          secretChanges = builtins.elem "secretChanges" cfg.log;
        };
      };
      checkPhase = ''
        ${sops-install-secrets}/bin/sops-install-secrets -check-mode=${
          if cfg.validateSopsFiles then "sopsfile" else "manifest"
        } "$out"
      '';
    };

  manifest = manifestFor "" cfg.secrets;

  script = toString (
    pkgs.writeShellScript "sops-nix-user" ''
      ${optionalString (cfg.gnupg.home != null) ''
        export SOPS_GPG_EXEC=${pkgs.gnupg}/bin/gpg
      ''}
      ${optionalString cfg.age.generateKey ''
        if [[ ! -f ${escapeShellArg cfg.age.keyFile} ]]; then
          echo "Generating machine-specific age key..."
          ${pkgs.coreutils}/bin/mkdir -p $(${pkgs.coreutils}/bin/dirname ${escapeShellArg cfg.age.keyFile})
          ${pkgs.age}/bin/age-keygen -o ${escapeShellArg cfg.age.keyFile}
        fi
      ''}
      ${sops-install-secrets}/bin/sops-install-secrets -ignore-passwd ${manifest}
    ''
  );

in
{
  options.services.sops-nix = {
    enable = mkEnableOption "sops-nix secret management";

    secrets = mkOption {
      type = types.attrsOf secretType;
      default = { };
      description = "Secrets to decrypt.";
    };

    defaultSopsFile = mkOption {
      type = types.path;
      description = "Default sops file used for all secrets.";
    };

    defaultSopsFormat = mkOption {
      type = types.str;
      default = "yaml";
      description = "Default sops format used for all secrets.";
    };

    validateSopsFiles = mkOption {
      type = types.bool;
      default = true;
      description = "Check all sops files at evaluation time.";
    };

    defaultSymlinkPath = mkOption {
      type = types.str;
      default = "${config.xdg.configHome}/sops-nix/secrets";
      description = "Default place where the latest generation of decrypted secrets can be found.";
    };

    defaultSecretsMountPoint = mkOption {
      type = types.str;
      default = "%r/secrets.d";
      description = "Default place where generations of decrypted secrets are stored.";
    };

    keepGenerations = mkOption {
      type = types.ints.unsigned;
      default = 1;
      description = "Number of secrets generations to keep.";
    };

    log = mkOption {
      type = types.listOf (
        types.enum [
          "keyImport"
          "secretChanges"
        ]
      );
      default = [
        "keyImport"
        "secretChanges"
      ];
      description = "What to log";
    };

    age = {
      keyFile = mkOption {
        type = types.nullOr (types.strMatching "^/");
        default = null;
        example = "/home/someuser/.age-key.txt";
        description = "Path to age key file used for sops decryption.";
      };

      generateKey = mkOption {
        type = types.bool;
        default = false;
        description = "Whether or not to generate the age key.";
      };

      sshKeyPaths = mkOption {
        type = types.listOf types.path;
        default = [ ];
        description = "Paths to ssh keys added as age keys during sops description.";
      };
    };

    gnupg = {
      home = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "/home/someuser/.gnupg";
        description = "Path to gnupg database directory containing the key for decrypting the sops file.";
      };

      sshKeyPaths = mkOption {
        type = types.listOf types.path;
        default = [ ];
        description = "Path to ssh keys added as GPG keys during sops description.";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions =
      [
        {
          assertion =
            cfg.gnupg.home != null
            || cfg.gnupg.sshKeyPaths != [ ]
            || cfg.age.keyFile != null
            || cfg.age.sshKeyPaths != [ ];
          message = "No key source configured for sops. Set sops.age.keyFile or sops.gnupg.home";
        }
        {
          assertion = !(cfg.gnupg.home != null && cfg.gnupg.sshKeyPaths != [ ]);
          message = "Exactly one of sops.gnupg.home and sops.gnupg.sshKeyPaths must be set";
        }
      ]
      ++ optionals cfg.validateSopsFiles (
        concatLists (
          mapAttrsToList (name: secret: [
            {
              assertion = pathExists secret.sopsFile;
              message = "Cannot find path '${secret.sopsFile}' set in sops.secrets.${strings.escapeNixIdentifier name}.sopsFile";
            }
            {
              assertion =
                isPath secret.sopsFile || (isString secret.sopsFile && hasPrefix builtins.storeDir secret.sopsFile);
              message = "'${secret.sopsFile}' is not in the Nix store. Either add it to the Nix store or set sops.validateSopsFiles to false";
            }
          ]) cfg.secrets
        )
      );

    build.activation.sops-nix = ''
      $VERBOSE_ECHO "Setting up sops-nix..."
      ${script}
    '';

    environment.packages = [
      (pkgs.writeScriptBin "sops-nix-run" ''
        #!${pkgs.runtimeShell}
        echo "Running sops-nix manually..."
        ${script}
      '')
    ];
  };
}
