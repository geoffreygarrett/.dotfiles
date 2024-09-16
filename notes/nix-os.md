- https://nixos.wiki/wiki/Ubuntu_vs.\_NixOS

# Ubuntu vs NixOS Comparison

| Task/Concept                      | Ubuntu                                                                                | NixOS (system-wide)                                                         | NixOS (user) / Nix in general                                    |
| --------------------------------- | ------------------------------------------------------------------------------------- | --------------------------------------------------------------------------- | ---------------------------------------------------------------- |
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

Note: This table provides a high-level comparison and doesn't cover all aspects
of both operating systems. For more detailed information, please refer to the
official documentation of Ubuntu and NixOS.

## Secrets

- https://lgug2z.com/articles/handling-secrets-in-nixos-an-overview/

## Articles

- https://fd93.me/nixos-to-ubuntu

# Repos

- https://github.com/numtide/system-manager

# Nix-on-Droid

- https://media.ccc.de/v/camp2023-57129-the_nix_phone_and_the_end_of_android

# Robitnix

- https://github.com/nix-community/robotnix?tab=readme-ov-file

# Any Linux

- https://github.com/numtide/system-manager

# Tails

- https://tails.net/install/linux/index.en.html

# nixos-generators - one config, multiple formats

- https://nixos.org/manual/nixos/stable/index.html#sec-building-image The
  nixos-generators project allows to take the same NixOS configuration, and
  generate outputs for different target formats.
- https://github.com/nix-community/nixos-generators/tree/master

# Learning Nix

- https://www.youtube.com/watch?v=a67Sv4Mbxmc&list=PLko9chwSoP-15ZtZxu64k_CuTzXrFpxPE&ab_channel=Vimjoyer

# Key Remapping

- https://github.com/xremap/xremap
- https://www.youtube.com/watch?v=UPWkQ3LUDOU&list=PLko9chwSoP-15ZtZxu64k_CuTzXrFpxPE&index=9&ab_channel=Vimjoyer


# Raspberry Pi

- [Installing NixOS on Raspberry Pi 4](https://mtlynch.io/nixos-pi4/)
- [NixOS on ARM/Raspberry Pi Official](https://nixos.wiki/wiki/NixOS_on_ARM/Raspberry_Pi)
- [myme's post with mention of deploy-rs](https://myme.no/posts/2022-12-01-nixos-on-raspberrypi.html)
- [Pablo's custom image](https://pablo.tools/blog/computers/nixos-generate-raspberry-images/)
- [Random cross compile](https://discourse.nixos.org/t/flake-to-create-a-simple-sd-image-for-rpi4-cross/35185)
# Dual Booting

- [Official](https://nixos.wiki/wiki/Dual_Booting_NixOS_and_Windows)

