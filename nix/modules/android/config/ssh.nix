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
    PidFile ${cfg.runtimeDir}/sshd.pid
    Subsystem sftp ${pkgs.openssh}/libexec/sftp-server
    ${cfg.extraConfig}
  '';

  startScript = pkgs.writeShellScriptBin "sshd-start" ''
    mkdir -p "${cfg.runtimeDir}"
    chmod 700 "${cfg.runtimeDir}"
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
    runtimeDir = mkOption {
      type = types.str;
      default = "$XDG_RUNTIME_DIR/sshd";
      description = "Directory to store runtime files like the PID file.";
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
        [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDxgVpVvAF4EmgJx5qMF4Mxr2FWluZ9..." ]
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

      $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "${config.user.home}/.ssh"
      $DRY_RUN_CMD echo "${concatStringsSep "\n" cfg.authorizedKeys}" > "${config.user.home}/.ssh/authorized_keys"
      $DRY_RUN_CMD chmod 700 "${config.user.home}/.ssh"
      $DRY_RUN_CMD chmod 600 "${config.user.home}/.ssh/authorized_keys"
      $DRY_RUN_CMD chown -R nix-on-droid:nix-on-droid "${config.user.home}/.ssh"

      $VERBOSE_ECHO "Setting up runtime directory..."
      $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "${cfg.runtimeDir}"
      $DRY_RUN_CMD chmod 700 "${cfg.runtimeDir}"
      $DRY_RUN_CMD chown nix-on-droid:nix-on-droid "${cfg.runtimeDir}"

      if [[ ! -d "${sshdDirectory}" ]]; then
        $DRY_RUN_CMD rm $VERBOSE_ARG --recursive --force "${sshdDirectory}-tmp"
        $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "${sshdDirectory}-tmp"

        $VERBOSE_ECHO "Generating host keys..."
        $DRY_RUN_CMD ssh-keygen -t rsa -b 4096 -f "${sshdDirectory}-tmp/ssh_host_rsa_key" -N ""
        $DRY_RUN_CMD ssh-keygen -t ed25519 -f "${sshdDirectory}-tmp/ssh_host_ed25519_key" -N ""

        $DRY_RUN_CMD mv $VERBOSE_ARG "${sshdDirectory}-tmp" "${sshdDirectory}"
      fi

      $VERBOSE_ECHO "Setting correct permissions..."
      $DRY_RUN_CMD chmod 600 "${sshdDirectory}/ssh_host_rsa_key" "${sshdDirectory}/ssh_host_ed25519_key"
      $DRY_RUN_CMD chmod 644 "${sshdDirectory}/ssh_host_rsa_key.pub" "${sshdDirectory}/ssh_host_ed25519_key.pub"
      $DRY_RUN_CMD chown -R nix-on-droid:nix-on-droid "${sshdDirectory}"

      $VERBOSE_ECHO "OpenSSH setup complete."
    '';

    # # Add SSH-related aliases
    # environment.shellAliases = {
    #   "sshd-stop" = "pkill sshd";
    #   "sshd-restart" = "sshd-stop && sshd-start";
    # };
  };
}
