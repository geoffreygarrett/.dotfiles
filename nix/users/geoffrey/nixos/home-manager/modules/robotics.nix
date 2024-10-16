{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nvidia-omniverse-launcher
  ];
}
