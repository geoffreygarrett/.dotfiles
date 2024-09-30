{ pkgs }:

let
in
# mkUserModule = username: {
#   nixosModules.${username} = import ./${username}/nixos;
#   darwinModules.${username} = import ./${username}/darwin;
#   homeManagerModules.${username} = import ./${username}/home-manager;
# };
#
# users = [ "geoffrey" ]; # Add more users here as needed
{
  # modules = builtins.foldl' (acc, username) (acc // (mkUserModule username)) {} users;
  #
  # # Function to get a specific user's modules
  # getUserModules = username: mkUserModule username;
}
