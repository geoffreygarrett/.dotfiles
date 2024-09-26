{
  description = "Nixus modules for abstracting services I revere across platforms";
  outputs =
    { self, nixpkgs, ... }:
    {
      nixosModules = {
        spotify = import ./modules/spotify/nixos.nix;
        kubernetes = import ./modules/kubernetes/nixos.nix;
        k3s = import ./modules/k3s/nixos.nix;
        # tailscale = import ./modules/tailscale/nixos.nix;
        # openssh = import ./modules/openssh/nixos.nix;
      };
      homeManagerModules = {
        spotify = import ./modules/spotify/home-manager.nix;
        kubernetes = import ./modules/kubernetes/home-manager.nix;
        k3s = import ./modules/k3s/home-manager.nix;
        # tailscale = import ./modules/tailscale/home-manager.nix;
        # openssh = import ./modules/openssh/home-manager.nix;
      };
      darwinModules = {
        spotify = import ./modules/spotify/darwin.nix;
        kubernetes = import ./modules/kubernetes/darwin.nix;
        k3s = import ./modules/k3s/darwin.nix;
        # tailscale = import ./modules/tailscale/darwin.nix;
        # openssh = import ./modules/openssh/darwin.nix;
      };
      nixosModules.default =
        { ... }:
        {
          imports = with self.nixosModules; [
            spotify
            kubernetes
            # tailscale
            # openssh
          ];
        };
      homeManagerModules.default =
        { ... }:
        {
          imports = with self.homeManagerModules; [
            spotify
            kubernetes
            # tailscale
            # openssh
          ];
        };
      darwinModules.default =
        { ... }:
        {
          imports = with self.darwinModules; [
            spotify
            kubernetes
            # tailscale
            # openssh
          ];
        };
    };
}
