{ config, pkgs, lib, ... }:

let
  # Write it to a temporary file to be used by Starship
  tomlConfig = builtins.fromTOML (builtins.readFile ../../config/starship/starship.toml);
in
{
  # Enable Starship prompt
  programs.starship = {
    enable = true;
#    settings = config.starship.content."starship.toml";
    settings = tomlConfig;

  };

  # Ensure Starship is available in your environment
  home.packages = [ pkgs.starship ];

  # Optional: Shell-specific initializations

  # For Bash
  programs.bash.initExtra = lib.mkIf config.programs.bash.enable ''
    eval "$(starship init bash)"
  '';

  # For Zsh
  programs.zsh.initExtra = lib.mkIf config.programs.zsh.enable ''
    eval "$(starship init zsh)"
  '';

  # For Fish
  programs.fish.interactiveShellInit = lib.mkIf config.programs.fish.enable ''
    starship init fish | source
  '';

#  # For Nushell
#  programs.nushell.initExtra = lib.mkIf config.programs.nushell.enable ''
#    starship init nu | save
#  '';
}
