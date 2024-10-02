(final: prev: {
  nix = prev.nix.overrideAttrs (old: {
    postInstall =
      (old.postInstall or "")
      + ''
        wrapProgram $out/bin/nix \
          --set NIX_IGNORE_EVALUATION_WARNINGS_REGEX "lib\.mdDoc will be removed from nixpkgs in 24\.11\."
      '';
  });
})
