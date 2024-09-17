{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.mdt;
in
{
  options.programs.mdt = {
    enable = mkEnableOption "mdt task manager";

    package = mkOption {
      type = types.package;
      default = pkgs.mdt;
      description = "The mdt package to use.";
    };

    settings = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Environment variables to configure mdt.";
      example = literalExpression ''
        {
          MDT_DIR = "~/tasks";
          MDT_INBOX = "~/tasks/inbox.md";
          MDT_MAIN_COLOR = "#5FAFFF";
          MDT_EDITOR = "nvim -c \"set nonumber\"";
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.sessionVariables = cfg.settings;

    programs.bash.shellAliases = mkIf config.programs.bash.enable {
      mdt = "mdt ${concatStringsSep " " (mapAttrsToList (name: value: 
        "--${toLower (removePrefix "MDT_" name)} '${value}'") cfg.settings)}";
    };

    programs.zsh.shellAliases = mkIf config.programs.zsh.enable {
      mdt = "mdt ${concatStringsSep " " (mapAttrsToList (name: value: 
        "--${toLower (removePrefix "MDT_" name)} '${value}'") cfg.settings)}";
    };
  };
}
