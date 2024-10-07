{ ... }:
{
  imports = [
    ./shared.nix
    ./modules/nixvim
  ];
  # home-manager = {
  #   users."geoffrey" = import ./home-manager/server.nix;
  # };
  #     home.activation = {
  #       generateSshKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  #         if [ ! -f $HOME/.ssh/id_ed25519 ]; then
  #           ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f $HOME/.ssh/id_ed25519 -N "" -C "${username}@${hostname}"
  #         fi
  #         if [ ! -f $HOME/.ssh/github_ed25519 ]; then
  #           ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f $HOME/.ssh/github_ed25519 -N "" -C "${username}@github"
  #         fi
  #       '';
  #     };
  #   }
}
