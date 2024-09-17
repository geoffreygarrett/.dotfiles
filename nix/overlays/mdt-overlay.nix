final: prev: {
  # Add the mdt package
  mdt = final.callPackage ../packages/shared/mdt.nix { };

  # Add the Home Manager module
  homeManagerModules = prev.homeManagerModules // {
    mdt = final.callPackage ../programs/mdt.nix { inherit (final) lib; };
  };
}
