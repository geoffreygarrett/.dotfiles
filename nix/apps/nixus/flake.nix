{
  description = "Nixus - Personal Nix-based system & environment management tool";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-on-droid = {
      url = "github:t184256/nix-on-droid";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
      nix-on-droid,
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ rust-overlay.overlays.default ];
          };
          rustPkgs = pkgs.rustPlatform;
        in
        {
          default = rustPkgs.buildRustPackage {
            pname = "nixus";
            version = "0.1.0";
            src = ./.;
            cargoLock = {
              lockFile = ./Cargo.lock;
            };
            buildFeatures = [ "${system}" ];
            buildInputs =
              with pkgs;
              [
                openssl
                pkg-config
                cachix
                nix
                jq
                gnugrep
              ]
              ++ pkgs.lib.optionals (pkgs.stdenv.isDarwin) [
                pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
              ]
              ++ pkgs.lib.optionals (pkgs.stdenv.isAndroid) [
                nix-on-droid.packages.${system}.nix-on-droid
              ];

            nativeBuildInputs = with pkgs; [
              pkg-config
              makeWrapper
            ];

            postInstall = ''
              wrapProgram $out/bin/nixus \
                --prefix PATH : ${
                  pkgs.lib.makeBinPath (
                    [
                      pkgs.cachix
                      pkgs.nix
                      pkgs.jq
                      pkgs.gnugrep
                    ]
                    ++ pkgs.lib.optionals (pkgs.stdenv.isAndroid) [
                      nix-on-droid.packages.${system}.nix-on-droid
                    ]
                    ++ pkgs.lib.optionals (pkgs.stdenv.isDarwin) [
                      pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
                    ]
                  )
                }
            '';

            meta = with pkgs.lib; {
              description = "Nixus - Personal Nix-based system & environment management tool";
              homepage = "https://github.com/geoffreygarrett/celestial-blueprint";
              license = licenses.mit;
              maintainers = with maintainers; [ "geoffreygarrett" ];
            };
          };
        }
      );
    };
}
