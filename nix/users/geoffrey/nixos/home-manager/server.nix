{
  ...
}@args:
{
  imports = [
    # Don't change
    ./shared.nix

    # Add after this comment
  ] ++ (import ../../home-manager/server.nix args).imports;
}
