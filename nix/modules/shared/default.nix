{ config, pkgs, ... }:

{


  #  nixpkgs = {
  #    config = {
  #      allowUnfree = true;
  #      #cudaSupport = true;
  #      #cudaCapabilities = ["8.0"];
  #      allowBroken = true;
  #      allowInsecure = false;
  #      allowUnsupportedSystem = true;
  #      allowUnfreePredicate = pkg: true;
  #    };
  #
  #    overlays =
  #      let
  #        path = ../../overlays;
  #        overlayFiles =
  #          with builtins;
  #          filter (n: match ".*\\.nix" n != null || pathExists (path + ("/" + n + "/default.nix"))) (
  #            attrNames (readDir path)
  #          );
  #      in
  #      builtins.trace "Loading overlays: ${builtins.toString overlayFiles}" (
  #        map (n: import (path + ("/" + n))) overlayFiles
  #      );
  #  };
}
