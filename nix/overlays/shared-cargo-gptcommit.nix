final: prev: {
  gptcommit = final.callPackage ./nix/packages/gptcommit.nix {
    #    inherit darwin;
    inherit (final)
      lib
      rustPlatform
      fetchFromGitHub
      openssl
      pkg-config
      stdenv
      ;
    #    inherit (final.darwin) apple_sdk;
  };
}
