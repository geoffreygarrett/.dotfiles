{ pkgs, lib }:

{ name, system, src ? ./. }:

let
  pkgsFor = system:
    import pkgs {
      inherit system;
      config.allowUnfree = true;
    };

  currentPkgs = pkgsFor system;

  scriptDir = currentPkgs.runCommand "${name}-dir" { } ''
    mkdir -p $out
    cp ${src}/nix/apps/${name}.rs $out/${name}.rs
    cp ${src}/nix/apps/shared.rs $out/shared.rs
  '';

in
{
  type = "app";
  program = toString (currentPkgs.writers.writeBash name ''
    export PATH=${currentPkgs.git}/bin:${currentPkgs.rust-script}/bin:$PATH
    exec rust-script ${scriptDir}/${name}.rs
  '');
}
