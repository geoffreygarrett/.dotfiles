{
  inputs,
  ...
}@args:
{
  imports = [
    # Don't change
    inputs.nix-colors.homeManagerModules.default

    # Add after this comment
  ];
  colorScheme = import ../../shared/nix-colors.nix;
  home.stateVersion = "24.11";
}
