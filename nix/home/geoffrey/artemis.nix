{ pkgs, ... }:
let
  user = "geoffreygarrett";
in
{
  imports = [ ./global ];
  home.username = "${user}";
  home.homeDirectory = "/Users/${user}";
  sops.age.keyFile = "Users/${user}/Library/Application Support/sops/age/keys.txt";
}
