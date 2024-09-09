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
    aliases = mkOption {
      type = types.attrsOf types.str;
      default = {
        sshd-start = "sshd-start";
        sshd-stop = "pkill sshd";
        sshd-restart = "sshd-stop && sshd-start";
      };
      description = "Aliases for SSH-related commands.";
    };
    sopsCallback = mkOption {
      type = types.nullOr (types.functionTo types.attrs);
      default = null;
      description = "Function to be called when SOPS becomes available. It should return an attrset of updated SSH options.";
    };
  };

  config = mkIf cfg.enable {
    environment.packages = with pkgs; [
      openssh
    ] ++ [
      (pkgs.writeScriptBin "sshd-start" ''
        #!${pkgs.runtimeShell}

        echo "Starting sshd in non-daemonized way on port ${toString cfg.port}"
        ${pkgs.openssh}/bin/sshd -f "${config.users.users.${config.user.name}.home}/sshd/sshd_config" -D -e
      '')
      (pkgs.writeScriptBin "sshd-update-config" ''
        #!${pkgs.runtimeShell}

        if [ -n "''${SOPS_AGE_KEY_FILE:-}" ]; then
          echo "SOPS is available. Updating SSH configuration..."
          ${optionalString (cfg.sopsCallback != null) ''
            # Call the SOPS callback function and update the configuration
            ${pkgs.nix}/bin/nix-instantiate --eval --expr '(import ${./ssh-module.nix} { inherit config lib pkgs; }).config.services.ssh.sopsCallback { }' | ${pkgs.jq}/bin/jq -r > /tmp/ssh_updated_config.json

            # Apply the updated configuration
            if [ -f /tmp/ssh_updated_config.json ]; then
              port=$(jq -r '.port // empty' /tmp/ssh_updated_config.json)
              authorizedKeys=$(jq -r '.authorizedKeys // empty' /tmp/ssh_updated_config.json)
              extraConfig=$(jq -r '.extraConfig // empty' /tmp/ssh_updated_config.json)

              if [ -n "$port" ]; then
                sed -i "s/^Port .*/Port $port/" ${config.users.users.${config.user.name}.home}/sshd/sshd_config
              fi

              if [ -n "$authorizedKeys" ]; then
                echo "$authorizedKeys" > ${config.users.users.${config.user.name}.home}/.ssh/authorized_keys
              fi

              if [ -n "$extraConfig" ]; then
                echo "$extraConfig" >> ${config.users.users.${config.user.name}.home}/sshd/sshd_config
              fi

              echo "SSH configuration updated. Restart the SSH server to apply changes."
            else
              echo "Failed to update SSH configuration."
            fi
          ''}
        else
          echo "SOPS is not yet available. SSH configuration remains unchanged."
        fi
      '')
    ];

    system.activationScripts.sshd = ''
            sshdTmpDirectory="${config.users.users.${config.user.name}.home}/sshd-tmp"
            sshdDirectory="${config.users.users.${config.user.name}.home}/sshd"

            $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "${config.users.users.${config.user.name}.home}/.ssh"
            $DRY_RUN_CMD echo "${concatStringsSep "\n" cfg.authorizedKeys}" > "${config.users.users.${config.user.name}.home}/.ssh/authorized_keys"
            $DRY_RUN_CMD chmod 600 "${config.users.users.${config.user.name}.home}/.ssh/authorized_keys"

            if [[ ! -d "$sshdDirectory" ]]; then
              $DRY_RUN_CMD rm $VERBOSE_ARG --recursive --force "$sshdTmpDirectory"
              $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "$sshdTmpDirectory"

              $VERBOSE_ECHO "Generating host keys..."
              for keyType in ${toString cfg.keyTypes}; do
                $DRY_RUN_CMD ${pkgs.openssh}/bin/ssh-keygen -t $keyType -f "$sshdTmpDirectory/ssh_host_''${keyType}_key" -N ""
              done

              $VERBOSE_ECHO "Writing sshd_config..."
              $DRY_RUN_CMD cat << EOF > "$sshdTmpDirectory/sshd_config"
              ${builtins.concatStringsSep "\n" (map (keyType: "HostKey ${config.users.users.${config.user.name}.home}/sshd/ssh_host_${keyType}_key") cfg.keyTypes)}
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

    #    environment.shellAliases = cfg.aliases // {
    #      sshd-update = "sshd-update-config";
    #    };
  };
}
