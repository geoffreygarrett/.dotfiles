{ lib, ... }:

{
  options.system.os = lib.mkOption {
    default = "nixos";
    type = lib.types.enum [
      "nixos"
      "linux"
      "darwin"
      "android"
    ];
  };
}
