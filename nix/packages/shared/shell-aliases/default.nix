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

  mkCompletion =
    name: command: shell:
    let
      commonSedCommand = "sed 's/^  *\\([a-z0-9-]*\\).*/\\1/' | grep '^[a-z0-9-]'";
      helpCommand = "${command} --help 2>&1 | ${commonSedCommand}";
    in
    {
      zsh = ''
        compdef _${name} ${name}
        function _${name} {
          _arguments "1: :($(${helpCommand}))"
        }
      '';
      bash = ''
        _${name}() {
          COMPREPLY=($(compgen -W "$(${helpCommand})" -- "''${COMP_WORDS[COMP_CWORD]}"))
        }
        complete -F _${name} ${name}
      '';
      fish = "complete -c ${name} -a \"(${helpCommand})\"";
      nu = ''
        def "${name}_completer" [] {
          ${helpCommand} | str replace -r ' .*' ''\''
        }
        def ${name} [...args: string@${name}_completer] {
          ${command} $args
        }
      '';
    }
    .${shell} or "";

  processAlias =
    name: def: shell:
    let
      isApplicable = isString def || (def ? command && (elem shell def.tags || def.tags == [ ]));
      command = if isString def then def else def.command;
      relevantTags = filter (tag: !(elem tag shellTypes)) (if isString def then [ ] else def.tags);
      tagString =
        if shell == "zsh" then
          ""
        else
          optionalString (relevantTags != [ ]) " # Tags: ${concatStringsSep ", " relevantTags}";
    in
    if isApplicable then
      {
        alias = nameValuePair name "${command}${tagString}";
        completion = mkCompletion name command shell;
      }
    else
      null;

  generateShellConfig =
    shell:
    let
      processedAliases = mapAttrsToList (name: def: processAlias name def shell) config.aliases.aliases;
      validAliases = filter (x: x != null) processedAliases;
    in
    {
      aliases = listToAttrs (map (x: x.alias) validAliases);
      completions = concatMapStringsSep "\n" (x: x.completion) validAliases;
    };

  aliasType = types.either types.str (
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
in
{
  options.aliases = {
    enable = mkEnableOption "shell aliases";
    aliases = mkOption {
      type = types.attrsOf aliasType;
      default = { };
      description = "Attribute set of shell aliases with commands, optional descriptions, and tags.";
    };
  };

  config = mkIf config.aliases.enable (
    let
      shellConfigs = genAttrs shellTypes generateShellConfig;
    in
    mkMerge ([
      (mkIf (config.programs.bash.enable or false) {
        programs.bash.shellAliases = shellConfigs.bash.aliases;
      })
      (mkIf (config.programs.zsh.enable or false) {
        programs.zsh.shellAliases = shellConfigs.zsh.aliases;
      })
      (mkIf (config.programs.fish.enable or false) {
        programs.fish.shellAliases = shellConfigs.fish.aliases;
      })
      (mkIf (config.programs.nushell.enable or false) {
        programs.nushell.shellAliases = shellConfigs.nu.aliases;
      })
    ]
    #    ++optional config.aliases.enable {
    ##      environment.interactiveShellInit = concatStringsSep "\n" (mapAttrsToList (shell: cfg: cfg.completions) shellConfigs);
    ##    }
    )
  );
}
