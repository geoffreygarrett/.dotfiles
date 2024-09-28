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
    UseDNS no
    StrictModes no
    LogLevel ${cfg.logLevel}
    PermitTTY ${if cfg.permitTTY then "yes" else "no"}
    PermitUserEnvironment yes
    ${cfg.extraConfig}
  '';

  startScript = pkgs.writeScriptBin "sshd-start" ''
    #!${pkgs.runtimeShell}
    set -e
    mkdir -p "${runtimeDir}" "${logDir}"
    export XDG_RUNTIME_DIR="${runtimeDir}"
    echo "Starting sshd in non-daemonized way on port ${toString cfg.port}"
    exec ${pkgs.openssh}/bin/sshd -f ${sshdConfigFile} -D -e
  '';

  testLoginScript = pkgs.writeScriptBin "test-login" ''
    #!${pkgs.runtimeShell}
    echo "Login successful. Testing environment..."
    env
    echo "Shell: $SHELL"
    echo "PATH: $PATH"
    echo "Test script completed."
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
        [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEXHjv1eLnnOF31FhCTAC/7LG7hSyyILzx/+ZgbvFhl7 user@host" ]
      '';
      description = "Public SSH keys that are allowed to connect.";
    };
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Additional configuration to append to sshd_config.";
    };
    logLevel = mkOption {
      type = types.enum [
        "QUIET"
        "FATAL"
        "ERROR"
        "INFO"
        "VERBOSE"
        "DEBUG"
        "DEBUG1"
        "DEBUG2"
        "DEBUG3"
      ];
      default = "INFO";
      description = "Logging level for sshd.";
    };
    permitTTY = mkOption {
      type = types.bool;
      default = true;
      description = "Specifies whether PTY allocation is permitted.";
    };
  };

  config = mkIf cfg.enable {
    environment.packages = with pkgs; [
      openssh
      startScript
      testLoginScript
    ];

    build.activation.sshd = pkgs.writeShellScript "activate-sshd" ''
      set -e
      export PATH="${
        lib.makeBinPath (
          with pkgs;
          [
            coreutils
            openssh
          ]
        )
      }"

      echo "Setting up OpenSSH..."
      mkdir -p "${config.user.home}/.ssh" "${sshdDirectory}" "${runtimeDir}" "${logDir}"

      if [[ ! -f "${config.user.home}/.ssh/authorized_keys" ]]; then
        echo "${concatStringsSep "\n" cfg.authorizedKeys}" > "${config.user.home}/.ssh/authorized_keys"
        chmod 600 "${config.user.home}/.ssh/authorized_keys"
      else
        echo "Authorized keys file already exists. Skipping..."
      fi

      chmod 700 "${config.user.home}/.ssh" "${sshdDirectory}" "${runtimeDir}" "${logDir}"

      if [[ ! -f "${sshdDirectory}/ssh_host_rsa_key" ]]; then
        echo "Generating RSA host key..."
        ssh-keygen -t rsa -b 4096 -f "${sshdDirectory}/ssh_host_rsa_key" -N ""
      fi

      if [[ ! -f "${sshdDirectory}/ssh_host_ed25519_key" ]]; then
        echo "Generating ED25519 host key..."
        ssh-keygen -t ed25519 -f "${sshdDirectory}/ssh_host_ed25519_key" -N ""
      fi

      echo "Setting correct permissions..."
      chmod 600 "${sshdDirectory}/ssh_host_rsa_key" "${sshdDirectory}/ssh_host_ed25519_key"
      chmod 644 "${sshdDirectory}/ssh_host_rsa_key.pub" "${sshdDirectory}/ssh_host_ed25519_key.pub"

      echo "OpenSSH setup complete."
    '';

    home.file.".ssh/environment".text = ''
      PATH=${
        lib.makeBinPath (
          with pkgs;
          [
            coreutils
            bash
          ]
        )
      }:$PATH
      SHELL=${pkgs.bash}/bin/bash
    '';

    home.file.".profile".text = ''
      if [ -n "$SSH_CONNECTION" ]; then
        ${testLoginScript}/bin/test-login
      fi
    '';
  };
}
