{
  description = "Custom packages flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      pkgsForSystem = system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };

      makeWrapper = pkgs:
        import ./make-wrapper.nix { inherit (pkgs) lib writeShellScriptBin; };
    in
    {
      packages = forAllSystems (system:
        let pkgs = pkgsForSystem system;
        in nixpkgs.lib.optionalAttrs (pkgs.stdenv.isDarwin) {
          tailscale-ui = pkgs.callPackage ./darwin/tailscale-ui.nix { };
          hammerspoon = pkgs.callPackage ./darwin/hammerspoon.nix { };
        });

      overlays.default = final: prev:
        nixpkgs.lib.optionalAttrs (prev.stdenv.isDarwin) {
          tailscale-ui = final.callPackage ./darwin/tailscale-ui.nix { };
          hammerspoon = final.callPackage ./darwin/hammerspoon.nix { };
        };
    };
}
