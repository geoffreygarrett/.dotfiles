{ pkgs, ... }: {
  imports = [ ./global ];
  home.username = "geoffreygarrett";
  home.homeDirectory = "/Users/geoffreygarrett";
  sops.age.keyFile =
    "Users/geoffreygarrett/Library/Application Support/sops/age/keys.txt";
}
