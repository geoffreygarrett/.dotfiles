{
  system,
  pkgs,
  lib,
  rust-overlay,
  nix-on-droid,
  ...
}:

let
  rustPkgs = pkgs.rustPlatform;

in
rustPkgs.buildRustPackage {
  pname = "nixus";
  version = "0.1.1";
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
    ++ pkgs.lib.optionals (lib.isDarwin system) [
      pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
    ]
    ++ pkgs.lib.optionals (lib.isAndroid system) [
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
          ++ pkgs.lib.optionals (lib.isAndroid system) [
            nix-on-droid.packages.${system}.nix-on-droid
          ]
          ++ pkgs.lib.optionals (lib.isDarwin system) [
            pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
          ]
        )
      }
  '';

  meta = with pkgs.lib; {
    description = "Nixus - My personal Nix-based system & environment management tool";
    homepage = "https://github.com/geoffreygarrett/celestial-blueprint";
    license = licenses.mit;
    maintainers = with maintainers; [ "geoffreygarrett" ];
  };
}
