{
  ...
}:
{
  nix.settings = {
    substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
      "https://geoffreygarrett.cachix.org"
      "https://nix-on-droid.cachix.org"
    ];

    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "geoffreygarrett.cachix.org-1:3WdQXTf/87KGswkvnb7otJxqz03NOmjGMHftGzqiR88="
      "nix-on-droid.cachix.org-1:56snoMJTXmE7wm+67YySRoTY64Zkivk9RT4QaKYgpkE="
      "builder-name:4w+NIGfO2WFJ6xKs4JaPoiUcxjm4YDG8ycLt3M67uBA=%" # geoffrey@apollo
    ];
  };
}
