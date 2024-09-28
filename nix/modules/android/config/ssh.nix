{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.openssh;
  sshdDirectory = "${config.user.home}/sshd";
  runtimeDir = "${config.user.home}/.run";
  logDir = "${config.user.home}/.local/log";

  sshdConfigFile = pkgs.writeText "sshd_config" ''
    HostKey ${sshdDirectory}/ssh_host_rsa_key
    HostKey ${sshdDirectory}/ssh_host_ed25519_key
    Port ${toString cfg.port}
    PermitRootLogin ${cfg.permitRootLogin}
    PasswordAuthentication ${if cfg.passwordAuthentication then "yes" else "no"}
    ChallengeResponseAuthentication no
    UsePAM no
    X11Forwarding no
    PrintMotd no
    AcceptEnv LANG LC_*
    Subsystem sftp ${pkgs.openssh}/libexec/sftp-server
    PidFile ${runtimeDir}/sshd.pid
    AuthorizedKeysFile ${config.user.home}/.ssh/authorized_keys
    UsePrivilegeSeparation no
    UseDNS no
    StrictModes no
    LogLevel DEBUG3
    ${cfg.extraConfig}
  '';

  startScript = pkgs.writeScriptBin "sshd-start" ''
    #!${pkgs.runtimeShell}
    mkdir -p "${runtimeDir}" "${logDir}"
    export XDG_RUNTIME_DIR="${runtimeDir}"
    echo "Starting sshd in non-daemonized way on port ${toString cfg.port}"
    ${pkgs.openssh}/bin/sshd -f ${sshdConfigFile} -D -e
  '';

in
{
  options.services.openssh = {
    enable = mkEnableOption "OpenSSH server";
    port = mkOption {
      type = types.port;
      default = 8022;
      description = "The port on which the SSH daemon listens.";
    };
    permitRootLogin = mkOption {
      type = types.enum [
        "yes"
        "no"
        "prohibit-password"
        "forced-commands-only"
      ];
      default = "no";
      description = "Whether and how the root user can log in via SSH.";
    };
    passwordAuthentication = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to allow password-based SSH authentication.";
    };
    authorizedKeys = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = literalExpression ''
        [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEXHjv1eLnnOF31FhCTAC/7LG7hSyyILzx/+ZgbvFhl7 geoffrey@artemis" ]
      '';
      description = "Public SSH keys that are allowed to connect.";
    };
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Additional configuration to append to sshd_config.";
    };
  };

  config = mkIf cfg.enable {
    environment.packages = with pkgs; [
      openssh
      startScript
    ];

    build.activation.sshd = pkgs.writeShellScript "activate-sshd" ''
      export PATH="${
        lib.makeBinPath (
          with pkgs;
          [
            coreutils
            openssh
          ]
        )
      }"

      $VERBOSE_ECHO "Setting up OpenSSH..."

      $DRY_RUN_CMD mkdir $VERBOSE_ARG -p "${config.user.home}/.ssh" "${sshdDirectory}" "${runtimeDir}" "${logDir}"
      $DRY_RUN_CMD echo "${concatStringsSep "\n" cfg.authorizedKeys}" > "${config.user.home}/.ssh/authorized_keys"
      $DRY_RUN_CMD chmod 700 "${config.user.home}/.ssh" "${sshdDirectory}" "${runtimeDir}" "${logDir}"
      $DRY_RUN_CMD chmod 600 "${config.user.home}/.ssh/authorized_keys"

      if [[ ! -f "${sshdDirectory}/ssh_host_rsa_key" ]]; then
        $VERBOSE_ECHO "Generating RSA host key..."
        $DRY_RUN_CMD ssh-keygen -t rsa -b 4096 -f "${sshdDirectory}/ssh_host_rsa_key" -N ""
      fi

      if [[ ! -f "${sshdDirectory}/ssh_host_ed25519_key" ]]; then
        $VERBOSE_ECHO "Generating ED25519 host key..."
        $DRY_RUN_CMD ssh-keygen -t ed25519 -f "${sshdDirectory}/ssh_host_ed25519_key" -N ""
      fi

      $VERBOSE_ECHO "Setting correct permissions..."
      $DRY_RUN_CMD chmod 600 "${sshdDirectory}/ssh_host_rsa_key" "${sshdDirectory}/ssh_host_ed25519_key"
      $DRY_RUN_CMD chmod 644 "${sshdDirectory}/ssh_host_rsa_key.pub" "${sshdDirectory}/ssh_host_ed25519_key.pub"

      $VERBOSE_ECHO "Creating necessary files..."
      $DRY_RUN_CMD touch "${logDir}/lastlog"

      $VERBOSE_ECHO "OpenSSH setup complete."
    '';

  };
}
