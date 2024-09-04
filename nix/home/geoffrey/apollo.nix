{ pkgs, ... }: {
  imports = [ ./global ];
  sops.age.keyFile = "/home/geoffrey/.config/sops/age/keys.txt";
}
