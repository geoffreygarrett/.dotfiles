{ lib, system, self, config, inputs, pkgs, ... }:

{
  nixpkgs = {
    config = {
      allowUnfree = true;
      #cudaSupport = true;
      #cudaCapabilities = ["8.0"];
      allowBroken = true;
      allowInsecure = false;
      allowUnsupportedSystem = true;
      allowUnfreePredicate = pkg: true;
    };

    overlays = [
      (final: prev: {
        nixus = self.packages.${system}.nixus;
      })
    ]
    ++ lib.optional (lib.isAndroid system) (
      final: prev: {
        nix-on-droid = inputs.nix-on-droid.packages.${system};
      }
    )
    ++ lib.optional (lib.isAndroid system) inputs.nix-on-droid.overlays.default
    ++ lib.optional (lib.isAndroid system) inputs.sops-nix.overlays.default
    ++ lib.optional (lib.isLinux system) inputs.nixgl.overlay;
  };

  treefmtEval = lib.forAllSystems (
    system: inputs.treefmt-nix.lib.evalModule (pkgs) ./nix/formatter/default.nix
  );

  overlays = let
    path = ../../overlays;
    overlayFiles =
      with builtins;
      filter (n: match ".*\\.nix" n != null || pathExists (path + ("/" + n + "/default.nix"))) (
        attrNames (readDir path)
      );
    in
    builtins.trace "Loading overlays: ${builtins.toString overlayFiles}" (
      map (n: import (path + ("/" + n))) overlayFiles
    );
}

