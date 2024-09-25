{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.custom.displays;

  monitorOpts =
    { name, config, ... }:
    {
      options = {
        fingerprint = mkOption {
          type = types.str;
          description = "EDID fingerprint of the monitor";
        };
        enable = mkEnableOption "this monitor";
        primary = mkOption {
          type = types.bool;
          default = false;
          description = "Whether this is the primary monitor";
        };
        position = mkOption {
          type = types.str;
          example = "0x0";
          description = "Position of the monitor";
        };
        mode = mkOption {
          type = types.str;
          example = "1920x1080";
          description = "Resolution of the monitor";
        };
        rate = mkOption {
          type = types.str;
          example = "60.00";
          description = "Refresh rate of the monitor";
        };
        rotate = mkOption {
          type = types.enum [
            "normal"
            "left"
            "right"
            "inverted"
          ];
          default = "normal";
          description = "Rotation of the monitor";
        };
        crtc = mkOption {
          type = types.nullOr types.int;
          default = null;
          description = "CRTC to use for this monitor";
        };
        dpi = mkOption {
          type = types.nullOr types.int;
          default = null;
          description = "DPI setting for this monitor";
        };
      };
    };

  hookOpts = types.submodule {
    options = {
      postswitch = mkOption {
        type = types.attrsOf types.lines;
        default = { };
        description = "Scripts to run after switching to a profile";
      };
      preswitch = mkOption {
        type = types.attrsOf types.lines;
        default = { };
        description = "Scripts to run before switching to a profile";
      };
      predetect = mkOption {
        type = types.attrsOf types.lines;
        default = { };
        description = "Scripts to run before autorandr attempts to detect displays";
      };
    };
  };

  mkProfile =
    monitors:
    nameValuePair "default" {
      fingerprint = mapAttrs (_: m: m.fingerprint) monitors;
      config = mapAttrs (_: m: removeAttrs m [ "fingerprint" ]) monitors;
    };

  mkHooks =
    hooks:
    mapAttrs (
      name: scripts:
      mapAttrs' (
        scriptName: script: nameValuePair "${name}/${scriptName}" (pkgs.writeScript scriptName script)
      ) scripts
    ) hooks;

in
{
  options.custom.displays = {
    enable = mkEnableOption "custom display configuration";

    monitors = mkOption {
      type = types.attrsOf (types.submodule monitorOpts);
      default = { };
      description = "Display configurations";
    };

    hooks = mkOption {
      type = hookOpts;
      default = { };
      description = "Hooks to run at various stages of display configuration";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = length (filter (m: m.primary) (attrValues cfg.monitors)) <= 1;
        message = "Only one monitor can be set as primary.";
      }
    ];

    services.autorandr = {
      enable = true;
      defaultTarget = "default";
      profiles = listToAttrs [ (mkProfile cfg.monitors) ];
      hooks = mkHooks cfg.hooks;
    };

    systemd.services.autorandr = {
      wantedBy = [ "graphical-session.target" ];
      # partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.autorandr}/bin/autorandr --change --default default";
      };
    };

    environment.systemPackages = [ pkgs.autorandr ];
  };
}
