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
    if shell == "zsh" then
      ''
        compdef _${name} ${name}
        function _${name} {
          _arguments "1: :($(${command} --help 2>&1 | sed 's/^  *\([a-z0-9-]*\).*/\1/' | grep '^[a-z0-9-]'))"
        }
      ''
    else if shell == "bash" then
      ''
        _${name}() {
          COMPREPLY=($(compgen -W "$(${command} --help 2>&1 | sed 's/^  *\([a-z0-9-]*\).*/\1/' | grep '^[a-z0-9-]')" -- "''${COMP_WORDS[COMP_CWORD]}"))
        }
        complete -F _${name} ${name}
      ''
    else if shell == "fish" then
      ''
        complete -c ${name} -a "(${command} --help 2>&1 | sed 's/^  *\([a-z0-9-]*\).*/\1/' | grep '^[a-z0-9-]')"
      ''
    else if shell == "nu" then
      ''
        def "${name}_completer" [] {
          ${command} --help 2>&1 | lines | find '  -' | str replace '  -' '-' | str replace -r ' .*' \'\'
        }
        def ${name} [...args: string@${name}_completer] {
          ${command} $args
        }
      ''
    else
      "";

  mkAliasConfig =
    name: def: shell:
    let
      relevantTags = filter (tag: !(elem tag shellTypes)) def.tags;
      tagString = optionalString (relevantTags != [ ]) " # Tags: ${concatStringsSep ", " relevantTags}";
      aliasCommand = "${def.command}${tagString}";
    in
    if (elem shell def.tags || def.tags == [ ]) then
      if shell == "nu" then
        {
          alias = "use ${name} = ${aliasCommand}";
          completion = mkCompletion name def.command shell;
        }
      else
        {
          alias = "alias ${name}='${aliasCommand}'";
          completion = mkCompletion name def.command shell;
        }
    else
      null;

  generateShellConfig =
    shell:
    let
      aliasConfigs = mapAttrsToList (name: def: mkAliasConfig name def shell) config.aliases.aliases;
      filteredConfigs = filter (x: x != null) aliasConfigs;
    in
    {
      aliases = concatMapStringsSep "\n" (config: config.alias) filteredConfigs;
      completions = concatMapStringsSep "\n" (config: config.completion) filteredConfigs;
    };

in
{
  options.aliases = {
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

  config = mkIf config.aliases.enable (
    let
      shellConfigs = genAttrs shellTypes generateShellConfig;
    in
    mkMerge [
      (mkIf (config.programs.bash.enable or false) {
        programs.bash.initExtra = mkDefault ''
          # Aliases
          ${shellConfigs.bash.aliases}

          # Completions
          ${shellConfigs.bash.completions}
        '';
      })
      (mkIf (config.programs.zsh.enable or false) {
        programs.zsh.initExtra = mkDefault ''
          # Aliases
          ${shellConfigs.zsh.aliases}

          # Completions
          ${shellConfigs.zsh.completions}
        '';
      })
      (mkIf (config.programs.fish.enable or false) {
        programs.fish.interactiveShellInit = mkDefault ''
          # Aliases
          ${shellConfigs.fish.aliases}

          # Completions
          ${shellConfigs.fish.completions}
        '';
      })
      (mkIf (config.programs.nushell.enable or false) {
        programs.nushell.extraConfig = mkDefault ''
          # Aliases and Completions
          ${shellConfigs.nu.completions}
          ${shellConfigs.nu.aliases}
        '';
      })
    ]
  );
}
