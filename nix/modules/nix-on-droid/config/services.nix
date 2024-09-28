{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.nix-on-droid;

  serviceOptions =
    { name, ... }:
    {
      options = {
        enable = mkEnableOption "Enable the ${name} service";
        description = mkOption {
          type = types.str;
          description = "Description of the service";
        };
        script = mkOption {
          type = types.str;
          description = "The script to run for this service";
        };
        preStart = mkOption {
          type = types.str;
          default = "";
          description = "Commands to run before starting the service";
        };
        postStop = mkOption {
          type = types.str;
          default = "";
          description = "Commands to run after stopping the service";
        };
        wantedBy = mkOption {
          type = types.listOf types.str;
          default = [ "default.target" ];
          description = "List of targets that want this service";
        };
        requires = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "List of services that this service requires";
        };
        after = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "List of services that must be started before this one";
        };
        autoStart = mkOption {
          type = types.bool;
          default = false;
          description = "Whether to start the service automatically on boot";
        };
        keepAlive = mkOption {
          type = types.bool;
          default = false;
          description = "Whether to keep the service alive when the app is in the background";
        };
        logFile = mkOption {
          type = types.str;
          default = "${config.user.home}/.nix-on-droid/logs/${name}.log";
          description = "Log file for the service";
        };
      };
    };

  mkServiceFile =
    name: serviceCfg:
    pkgs.writeText "${name}-service" ''
      #!/bin/sh
      mkdir -p $(dirname ${serviceCfg.logFile})  # Ensure log directory exists
      echo "Starting ${name} service..." | tee -a ${serviceCfg.logFile}
      if [ -n "${serviceCfg.preStart}" ]; then
        echo "Running pre-start commands for ${name}..." | tee -a ${serviceCfg.logFile}
        ${serviceCfg.preStart} 2>&1 | tee -a ${serviceCfg.logFile}
      fi
      echo "Running main script for ${name}..." | tee -a ${serviceCfg.logFile}
      ${serviceCfg.script} 2>&1 | tee -a ${serviceCfg.logFile}
      if [ -n "${serviceCfg.postStop}" ]; then
        echo "Running post-stop commands for ${name}..." | tee -a ${serviceCfg.logFile}
        ${serviceCfg.postStop} 2>&1 | tee -a ${serviceCfg.logFile}
      fi
      echo "Stopping ${name} service..." | tee -a ${serviceCfg.logFile}
    '';

  # Function to start a service manually
  # Function to start a service manually
  startServiceManuallyScript = pkgs.writeShellScriptBin "start-service" ''
    #!/bin/sh
    if [ $# -ne 1 ]; then
      echo "Usage: $0 <service-name>"
      exit 1
    fi
    serviceFile="${config.user.home}/.nix-on-droid/services/$1"
    logFile="${config.user.home}/.nix-on-droid/logs/$1.log"
    if [ -f "$serviceFile" ] && [ -x "$serviceFile" ]; then
      echo "Manually starting $1 with supervise..." | tee -a $logFile
      controlfd=$(mktemp)
      statusfd=$(mktemp)
      ${pkgs.supervise}/bin/supervise "$controlfd" "$statusfd" "$serviceFile" &
      if [ -f "${config.user.home}/.nix-on-droid/services/$1.keepalive" ]; then
        disown %1
        echo "Service $1 is running in the background (keepAlive)." | tee -a $logFile
      fi
    else
      echo "Service $1 not found or not executable." | tee -a $logFile
    fi
  '';
in
{
  options = {
    nix-on-droid = {
      services = mkOption {
        type = types.attrsOf (types.submodule serviceOptions);
        default = { };
        description = "Attribute set of services";
      };
    };
  };

  config = {
    build.activation.setupServices = ''
      mkdir -p ${config.user.home}/.nix-on-droid/services
      mkdir -p ${config.user.home}/.nix-on-droid/logs
      ${concatStringsSep "\n" (
        mapAttrsToList (
          name: serviceCfg:
          optionalString serviceCfg.enable ''
            echo "${serviceCfg.description}" > ${config.user.home}/.nix-on-droid/services/${name}.description
            ln -sf ${mkServiceFile name serviceCfg} ${config.user.home}/.nix-on-droid/services/${name}
            chmod +x ${config.user.home}/.nix-on-droid/services/${name}
            ${optionalString serviceCfg.autoStart ''
              touch ${config.user.home}/.nix-on-droid/services/${name}.autostart
            ''}
            ${optionalString serviceCfg.keepAlive ''
              touch ${config.user.home}/.nix-on-droid/services/${name}.keepalive
            ''}
          ''
        ) cfg.services
      )}
    '';

    build.activation.startServices = ''
      for serviceFile in ${config.user.home}/.nix-on-droid/services/*; do
        if [ -f "$serviceFile" ] && [ -x "$serviceFile" ]; then
          serviceName=$(basename "$serviceFile")
          if [ -f "${config.user.home}/.nix-on-droid/services/$serviceName.autostart" ]; then
            controlfd=$(mktemp)
            statusfd=$(mktemp)
            mkdir -p ${config.user.home}/.nix-on-droid/logs
            echo "Launching $serviceName with supervise..." | tee -a ${config.user.home}/.nix-on-droid/logs/$serviceName.log
            ${pkgs.supervise}/bin/supervise "$controlfd" "$statusfd" "$serviceFile" &
            if [ -f "${config.user.home}/.nix-on-droid/services/$serviceName.keepalive" ]; then
              disown %1
              echo "Service $serviceName is running in the background (keepAlive)." | tee -a ${config.user.home}/.nix-on-droid/logs/$serviceName.log
            fi
          fi
        fi
      done
    '';

    environment.packages = [
      pkgs.supervise
      startServiceManuallyScript
    ];
  };
}
