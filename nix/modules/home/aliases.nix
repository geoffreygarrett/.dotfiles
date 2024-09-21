{
  lib,
  config,
  pkgs,
  ...
}:

with lib;

let
  shellTypes = [
    "bash"
    "zsh"
    "fish"
    "nu"
  ];
in
{
  options.home.aliases = {
    enable = mkEnableOption "shell aliases";

    aliases = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            command = mkOption {
              type = types.str;
              description = "The command to be aliased.";
            };
            description = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Optional description of the alias.";
            };
            tags = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "List of tags for organization and shell specification.";
            };
          };
        }
      );
      default = { };
      description = "Attribute set of shell aliases with commands, optional descriptions, and tags.";
    };
  };

  config = mkIf config.home.aliases.enable (
    let
      shellAliases =
        shell:
        mapAttrsToList (
          alias: info:
          let
            relevantTags = filter (tag: !(elem tag shellTypes)) info.tags;
            tagString = optionalString (relevantTags != [ ]) " # Tags: ${concatStringsSep ", " relevantTags}";
          in
          if (elem shell info.tags || info.tags == [ ]) then
            {
              name = alias;
              value = "${info.command}${tagString}";
            }
          else
            null
        ) config.home.aliases.aliases;

      filteredAliases = shell: filter (x: x != null) (shellAliases shell);

      bashZshAliases =
        shell:
        concatStringsSep "\n" (map (alias: "alias ${alias.name}='${alias.value}'") (filteredAliases shell));

      fishAliases = concatStringsSep "\n" (
        map (alias: "alias ${alias.name} '${alias.value}'") (filteredAliases "fish")
      );

      nuAliases = concatStringsSep "\n" (
        map (alias: "alias ${alias.name} = ${alias.value}") (filteredAliases "nu")
      );
    in
    mkMerge [
      {
        programs.bash.initExtra = ''
          # Aliases
          ${bashZshAliases "bash"}
        '';

        programs.zsh.initExtra = ''
          # Aliases
          ${bashZshAliases "zsh"}
        '';

        programs.fish.interactiveShellInit = ''
          # Aliases
          ${fishAliases}
        '';

        # FIXME: Incorrect syntax generated. Run `nu` for error.
        programs.nushell.extraConfig = ''
          # Aliases
          ${nuAliases}
        '';
      }
    ]
  );
}
