{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  starshipInit = shell: ''
    ${config.programs.starship.package}/bin/starship init ${shell}
  '';
in
{
  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile "${inputs.self}/dotfiles/starship/starship.toml");
  };

  programs.bash.initExtra = lib.mkIf (
    config.programs.bash.enable && config.programs.starship.enable
  ) ''eval "$(${starshipInit "bash"})"'';

  programs.zsh.initExtra = lib.mkIf (config.programs.zsh.enable && config.programs.starship.enable) ''
    # Workaround for the missing starship_zle-keymap-select function issue.
    # See https://github.com/starship/starship/issues/3418 for more details.

  '';
  #    type starship_zle-keymap-select >/dev/null || {
  #      echo "Loading starship explicitly due to the known issue with zle-keymap-select"
  #      eval "$(${starshipInit "zsh"})"
  #    }
  programs.fish.interactiveShellInit = lib.mkIf (
    config.programs.fish.enable && config.programs.starship.enable
  ) "${starshipInit "fish"} | source";

  # Example for extending the configuration to nushell, if needed in the future.
  # programs.nushell.extraConfig = lib.mkIf (
  #   config.programs.nushell.enable && config.programs.starship.enable
  # ) "${starshipInit "nu"} | save -f ~/.cache/starship/init.nu; source ~/.cache/starship/init.nu";
}
