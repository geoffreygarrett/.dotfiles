{ lib, stdenv, stdenvNoCC, fetchurl, unzip }:
{
  hammerspoon = import ./hammerspoon.nix { inherit lib stdenvNoCC fetchurl unzip; };
}