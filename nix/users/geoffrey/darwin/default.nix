{
  config,
  lib,
  pkgs,
  ...
}:
{
  users.users.geoffrey = {
    name = "geoffrey";
    home = "/Users/geoffrey";
    shell = pkgs.zsh;
  };

  # Enable zsh system-wide
  programs.zsh.enable = true;

  # Since macOS doesn't use sudo group, we use dseditgroup to add geoffrey to admin group
  system.activationScripts.postActivation.text = ''
    ${pkgs.darwin.shell_scripts}/bin/dseditgroup -o edit -a geoffrey -t user admin
  '';
}
