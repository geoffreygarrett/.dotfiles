let
  nixpkgs = fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixpkgs-unstable.tar.gz";
    sha256 = "1vncvmr80wa1mb0di6vfw4hs794j12zhvb96v8rk5rsxhwgw2r1i";
  };
  pkgs = import nixpkgs { };
  aerospace = pkgs.callPackage ./aerospace.nix { };
in
aerospace
