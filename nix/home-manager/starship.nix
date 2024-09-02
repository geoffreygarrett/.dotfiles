{ config, pkgs, lib, ... }:

let
  tomlConfig = builtins.fromTOML (builtins.readFile ../../config/starship/starship.toml);
in
{
  programs.starship = {
    enable = true;
    settings = tomlConfig;
  };
  home.packages = [ pkgs.starship ];
  programs.bash.initExtra = lib.mkIf config.programs.bash.enable ''
    eval "$(starship init bash)"
  '';
  programs.zsh.initExtra = lib.mkIf config.programs.zsh.enable ''
    eval "$(starship init zsh)"
  '';
  programs.fish.interactiveShellInit = lib.mkIf config.programs.fish.enable ''
    starship init fish | source
  '';
}
