{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.ssh;
in
{
  options.services.ssh = {
    enable = mkEnableOption "SSH server";
    port = mkOption {
      type = types.port;
      default = 8022;
      description = "The port on which the SSH server will listen.";
    };
    authorizedKeys = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDxgVpVvAF4EmgJx5qMF4Mxr2FWluZ9..."
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKNeSiY+6qmUkGrLu9Zjy5EcVWGVWgkeoC4..."
      ];
      description = "The public keys that are allowed to connect.";
    };
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Additional configuration to be appended to sshd_config.";
    };
    keyTypes = mkOption {
      type = types.listOf types.str;
      default = [ "rsa" "ed25519" ];
      description = "The types of SSH keys to generate.";
    };
  };

  config = mkIf cfg.enable {
    environment.packages = with pkgs; [
      openssh
    ] ++ [
      (pkgs.writeScriptBin "sshd-start" ''
        #!${pkgs.runtimeShell}

        echo "Starting sshd in non-daemonized way on port ${toString cfg.port}"
        ${openssh}/bin/sshd -f "${config.user.home}/sshd/sshd_config" -D -e
      '')
    ];

    build.activation.sshd = ''
            sshdTmpDirectory="${config.user.home}/sshd-tmp"
            sshdDirectory="${config.user.home}/sshd"

            $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "${config.user.home}/.ssh"
            $DRY_RUN_CMD echo "${concatStringsSep "\n" cfg.authorizedKeys}" > "${config.user.home}/.ssh/authorized_keys"
            $DRY_RUN_CMD chmod 600 "${config.user.home}/.ssh/authorized_keys"

            if [[ ! -d "$sshdDirectory" ]]; then
              $DRY_RUN_CMD rm $VERBOSE_ARG --recursive --force "$sshdTmpDirectory"
              $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "$sshdTmpDirectory"

              $VERBOSE_ECHO "Generating host keys..."
              for keyType in ${toString cfg.keyTypes}; do
                $DRY_RUN_CMD ${pkgs.openssh}/bin/ssh-keygen -t $keyType -f "$sshdTmpDirectory/ssh_host_''${keyType}_key" -N ""
              done

              $VERBOSE_ECHO "Writing sshd_config..."
              $DRY_RUN_CMD cat << EOF > "$sshdTmpDirectory/sshd_config"
              ${builtins.concatStringsSep "\n" (map (keyType: "HostKey ${config.user.home}/sshd/ssh_host_${keyType}_key") cfg.keyTypes)}
              Port ${toString cfg.port}
              PermitRootLogin no
              PasswordAuthentication no
              ChallengeResponseAuthentication no
              UsePAM no
              X11Forwarding no
              PrintMotd no
              AcceptEnv LANG LC_*
              Subsystem sftp ${pkgs.openssh}/libexec/sftp-server
              ${cfg.extraConfig}
      EOF

              $DRY_RUN_CMD mv $VERBOSE_ARG "$sshdTmpDirectory" "$sshdDirectory"
            fi
    '';

    options.services.ssh.aliases = mkOption {
      type = types.attrsOf types.str;
      default = {
        sshd-start = "sshd-start";
        sshd-stop = "pkill sshd";
        sshd-restart = "sshd-stop && sshd-start";
      };
      description = "Aliases for SSH-related commands.";
    };

    #    # Add SSH-related aliases to the custom shell aliases module
    #    custom.shellAliases.aliases = mkIf config.custom.shellAliases.enable {
    #      sshd-start = { command = "sshd-start"; priority = 50; };
    #      sshd-stop = { command = "pkill sshd"; priority = 50; };
    #      sshd-restart = { command = "sshd-stop && sshd-start"; priority = 50; };
    #    };
  };
}
