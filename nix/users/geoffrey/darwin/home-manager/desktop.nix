{
  pkgs,
  ...
}@args:
{
  imports = [
    # Don't change
    ./shared.nix

    # Add after this comment
  ] ++ (import ../../home-manager/desktop.nix args).imports;
}
