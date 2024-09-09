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
  version = "0.1.0";
  src = ./.; # Assuming you're in the nixus directory
  cargoLock = {
    lockFile = ./Cargo.lock;
  };
  buildFeatures = [ "${system}" ];
  #    preBuild = ''
  #      if ! ${pkgs.nix-on-droid} --version > /dev/null 2>&1; then
  #        echo "Error: nix-on-droid not found" >&2
  #        exit 1
  #      fi
  #    '';

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

  #  propagatedBuildInputs = with pkgs; [
  #    cachix
  #    nix
  #    jq
  #    gnugrep
  #  ] ++ pkgs.lib.optionals (system == "aarch64-linux") [
  #    pkgs.nix-on-droid
  #  ];

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
        )
      }
  '';

  meta = with pkgs.lib; {
    description = "Nixus - A Nix-based system management tool";
    homepage = "https://github.com/geoffreygarrett/celestial-blueprint";
    license = licenses.mit;
    maintainers = with maintainers; [ "geoffreygarrett" ];
  };
}
