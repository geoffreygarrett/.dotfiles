{ config, pkgs, ... }:

{
  programs.zsh.enable = true;

  security = {
    rtkit.enable = true;
    sudo = {
      enable = true;
      extraRules = [{
        commands = [{
          command = "${pkgs.systemd}/bin/reboot";
          options = [ "NOPASSWD" ];
        }];
        groups = [ "wheel" ];
      }];
    };
  };
}
