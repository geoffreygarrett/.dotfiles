{
  ...
}@args:
{
  imports = [
    # Don't change
    ./shared.nix

    # Add after this comment
  ] ++ (import ../../home-manager/default.nix args).imports;
}
