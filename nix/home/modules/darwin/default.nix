{ config, lib, pkgs, home-manager, ... }:

let cfg = config.my.darwin;
in { }

#{ config, pkgs, agenix, secrets, ... }:
#
#let
#  tailscale-ui = pkgs.callPackage ./tailscale-ui.nix { };
#  hammerspoon = pkgs.callPackage ./hammerspoon.nix { };
#
#in
#  user = "geoffreygarrett";

#{

#  age = {
#    identityPaths = [
#      "/Users/${user}/.ssh/id_ed25519"
#    ];
#
#    secrets = {
#      "syncthing-cert" = {
#        symlink = true;
#        path = "/Users/${user}/Library/Application Support/Syncthing/cert.pem";
#        file = "${secrets}/darwin-syncthing-cert.age";
#        mode = "644";
#        owner = "${user}";
#        group = "staff";
#      };
#
#      "syncthing-key" = {
#        symlink = true;
#        path = "/Users/${user}/Library/Application Support/Syncthing/key.pem";
#        file = "${secrets}/darwin-syncthing-key.age";
#        mode = "600";
#        owner = "${user}";
#        group = "staff";
#      };
#
#      "github-ssh-key" = {
#        symlink = true;
#        path = "/Users/${user}/.ssh/id_github";
#        file = "${secrets}/github-ssh-key.age";
#        mode = "600";
#        owner = "${user}";
#        group = "staff";
#      };
#
#      "github-signing-key" = {
#        symlink = false;
#        path = "/Users/${user}/.ssh/pgp_github.key";
#        file = "${secrets}/github-signing-key.age";
#        mode = "600";
#        owner = "${user}";
#      };
#    };
#  };
#}
