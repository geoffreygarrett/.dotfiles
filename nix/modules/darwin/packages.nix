{ pkgs }:
with pkgs;
let
  shared-packages = import ../shared/packages { inherit pkgs; };
in
shared-packages
++ [
  fswatch
  #dockutil # NOTE: Build swift
  darwin.apple_sdk.frameworks.Security
  darwin.apple_sdk.frameworks.CoreFoundation
  darwin.apple_sdk.frameworks.CoreServices
]
