- https://nixos.wiki/wiki/Ubuntu_vs._NixOS

# Ubuntu vs NixOS Comparison

| Task/Concept                      | Ubuntu                                                                                | NixOS (system-wide)                                                         | NixOS (user) / Nix in general                                    |
|-----------------------------------|---------------------------------------------------------------------------------------|-----------------------------------------------------------------------------|------------------------------------------------------------------|
| Package Manager                   | apt (running on top of dpkg)                                                          | nix (with nixos packages for system-wide operations)                        | nix                                                              |
| Who can install packages          | Only root can install packages (system-wide)                                          | Root installs system-wide packages through /etc/nixos/configuration.nix     | Users can install their own packages and have their own profiles |
| Package installation location     | Globally in /bin/, /usr/, etc.                                                        | System-wide: /run/current-system/sw/ and /nix/var/nix/profiles/default/bin/ | User packages: ~/.nix-profile/                                   |
| Major version selection           | Change sources.list and apt-get dist-upgrade (infrequent and potentially destructive) | Select from channels, easy to switch or rollback                            | Per-user if not set by root                                      |
| Install a package (all users)     | `sudo apt-get install emacs`                                                          | 1. Add to /etc/nixos/configuration.nix<br>2. `sudo nixos-rebuild switch`    | `nix-env -iA nixos.emacs`                                        |
| Install a package (specific user) | Not possible                                                                          | Configure in /etc/nixos/configuration.nix for specific user                 | Configure in ~/.nixpkgs/config.nix                               |
| Uninstall a package               | `sudo apt-get remove emacs`                                                           | Remove from /etc/nixos/configuration.nix and rebuild                        | `nix-env --uninstall emacs`                                      |
| Update package list               | `sudo apt-get update`                                                                 | `sudo nix-channel --update`                                                 | `nix-channel --update`                                           |
| Upgrade packages                  | `sudo apt-get upgrade`                                                                | `sudo nixos-rebuild switch`                                                 | `nix-env -u`                                                     |
| List package dependencies         | `apt-cache depends emacs`                                                             | `nix-store --query --requisites /run/current-system`                        | `nix-store --query --references $(which emacs)`                  |
| Verify installed packages         | `debsums`                                                                             | `sudo nix-store --verify --check-contents`                                  | `nix-store --verify --check-contents`                            |
| Configure a package               | `sudo dpkg-reconfigure <package>`                                                     | Edit /etc/nixos/configuration.nix                                           | Edit ~/.nixpkgs/config.nix                                       |
| Find packages                     | `apt-cache search emacs`                                                              | `nix-env -qaP '.*emacs.*'` or `nix search nixpkgs emacs`                    | Same as system-wide                                              |
| Start a service                   | `sudo systemctl start apache`                                                         | Same as Ubuntu                                                              | N/A                                                              |
| Enable a service                  | `sudo systemctl enable apache`                                                        | Configure in /etc/nixos/configuration.nix, then `sudo nixos-rebuild switch` | N/A                                                              |
| Add a user                        | `sudo adduser alice`                                                                  | Configure in /etc/nixos/configuration.nix, then `nixos-rebuild switch`      | N/A                                                              |
| Get current version               | `cat /etc/debian_version`                                                             | `nixos-version`                                                             | N/A                                                              |

Note: This table provides a high-level comparison and doesn't cover all aspects of both operating systems. For more
detailed information, please refer to the official documentation of Ubuntu and NixOS.

## Secrets

- https://lgug2z.com/articles/handling-secrets-in-nixos-an-overview/


## Amazing 

- https://github.com/dustinlyons/nixos-config/tree/main