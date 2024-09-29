{
  description = "Nixus modules for abstracting services I revere across platforms";
  outputs =
    { self, nixpkgs, ... }:
    {

      nixOnDroidModules = {
        # spotify = import ./modules/spotify/nix-on-droid.nix;
        # kubernetes = import ./modules/kubernetes/nix-on-droid.nix;
        # k3s = import ./modules/k3s/nix-on-droid.nix;
        # dnsmasq = import ./modules/dnsmasq/nix-on-droid.nix;
        # tailscale = import ./modules/tailscale/nix-on-droid.nix;
        openssh = import ./modules/openssh/nix-on-droid.nix;
      };
      nixosModules = {
        spotify = import ./modules/spotify/nixos.nix;
        kubernetes = import ./modules/kubernetes/nixos.nix;
        k3s = import ./modules/k3s/nixos.nix;
        dnsmasq = import ./modules/dnsmasq/nixos.nix;
        # tailscale = import ./modules/tailscale/nixos.nix;
        # openssh = import ./modules/openssh/nixos.nix;
      };
      homeManagerModules = {
        spotify = import ./modules/spotify/home-manager.nix;
        kubernetes = import ./modules/kubernetes/home-manager.nix;
        k3s = import ./modules/k3s/home-manager.nix;
        dnsmasq = import ./modules/dnsmasq/home-manager.nix;
        # tailscale = import ./modules/tailscale/home-manager.nix;
        # openssh = import ./modules/openssh/home-manager.nix;
      };
      darwinModules = {
        spotify = import ./modules/spotify/darwin.nix;
        kubernetes = import ./modules/kubernetes/darwin.nix;
        k3s = import ./modules/k3s/darwin.nix;
        dnsmasq = import ./modules/dnsmasq/darwin.nix;
        # tailscale = import ./modules/tailscale/darwin.nix;
        # openssh = import ./modules/openssh/darwin.nix;
      };
      nixOnDroidModules.default =
        { ... }:
        {
          imports = with self.nixOnDroidModules; [
            # spotify
            # kubernetes
            # k3s
            # dnsmasq
            # tailscale
            openssh
          ];
        };
      nixosModules.default =
        { ... }:
        {
          imports = with self.nixosModules; [
            spotify
            kubernetes
            dnsmasq
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
            dnsmasq
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
            dnsmasq
            # tailscale
            # openssh
          ];
        };
    };
}
