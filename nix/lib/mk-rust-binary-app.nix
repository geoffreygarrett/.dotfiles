{ pkgs, lib }:

{ name, system, src ? ./., dependencies ? [ ] }:

let
  pkgsFor = system:
    import pkgs {
      inherit system;
      config.allowUnfree = true;
    };

  currentPkgs = pkgsFor system;
  rustPlatform = currentPkgs.rustPlatform;

in
rustPlatform.buildRustPackage {
  pname = name;
  version = "0.1.0";
  src = lib.cleanSource src;

  cargoLock = { lockFile = "${src}/Cargo.lock"; };

  buildInputs = dependencies;

  meta = with lib; {
    description = "A Rust binary application";
    license = licenses.mit;
  };
}
