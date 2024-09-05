{ pkgs, lib, ... }:

let
  toml = builtins.fromTOML (builtins.readFile ./aliases.toml);

  getPackage = name: pkgs.${builtins.getAttr name toml.packages};

  generateAlias = name: alias:
    let
      command = if alias.dependency != null then
        "${
          getPackage alias.dependency
        }/bin/${alias.dependency} ${alias.command}"
      else
        alias.command;
    in lib.nameValuePair name command;

  generateShellAliases = shell:
    lib.listToAttrs (lib.filter (alias: builtins.elem shell alias.shells)
      (lib.mapAttrsToList generateAlias toml.aliases));

in {
  shellAliases = {
    zsh = generateShellAliases "zsh";
    bash = generateShellAliases "bash";
    fish = generateShellAliases "fish";
    nu = generateShellAliases "nu";
  };
}
