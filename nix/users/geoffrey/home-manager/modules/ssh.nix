{
  config,
  lib,
  pkgs,
  username,
  ...
}:

{
  home.file.".ssh/authorized_keys".text = ''
    ssh-dss AAAAB3Nza... alice@foobar
  '';

  home.activation = {
    generateSshKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f ${config.home.homeDirectory}/.ssh/id_ed25519 ]; then
        ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f ${config.home.homeDirectory}/.ssh/id_ed25519 -N "" -C "${username}@$(hostname)"
      fi
    '';
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "*" = {
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };
}
