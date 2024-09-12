The following sections relate to errors I encountered in specific systems, but may not be exclusive
to that specific system it's listed under.

# macOS

## Problem with the SSL CA cert (path? access rights?)

I had this error upon changing my username for my mac user and having to uninstall and reinstall nix.

```
error: unable to download 'https://cache.nixos.org/6m2s954xj4gcwgrz8azk4y5siz0nb3ih.narinfo': Problem with the SSL CA cert (path? access rights?) (77)
```

Solved by [this](https://github.com/NixOS/nix/issues/8771#issuecomment-1662633816):

```bash
sudo rm /etc/ssl/certs/ca-certificates.crt
sudo ln -s /nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt
```