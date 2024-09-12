# `nixus-core`

## Table of Contents

- [Introduction](#introduction)
- [Supported Platforms and Frameworks](#supported-platforms-and-frameworks)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Key Components](#key-components)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)

## Introduction

Nixus Device System is a cross-platform terminal setup project aimed at
providing a consistent and powerful environment across various devices and
operating systems. By leveraging Nix and related technologies, we offer
system-level integration, secret management, VPN solutions, and more for a
seamless experience across desktop and mobile platforms, as well as standalone
Home Manager configurations.

## Supported Platforms and Frameworks

- [Home Manager](https://github.com/nix-community/home-manager): Standalone user
  environment management
- [NixOS](https://nixos.org/): Full system-level integration
- [nix-darwin](https://github.com/LnL7/nix-darwin): macOS system-level
  integration
- [Nix-on-Droid](https://github.com/nix-community/nix-on-droid): Android
  integration (aarch64-linux only)
- [Mobile NixOS](https://github.com/mobile-nixos/mobile-nixos): Experimental
  mobile device support

## Features

| Feature                                                           | Home | NixOS | macOS (nix-darwin) | Android (Nix-on-Droid) | Mobile NixOS |
| ----------------------------------------------------------------- | :--: | :---: | :----------------: | :--------------------: | :----------: |
| System-level integration                                          | N/A  |  ⚫   |         🟢         |           🟢           |      ⚫      |
| Secret management ([sops-nix](https://github.com/Mic92/sops-nix)) |  🟢  |  ⚫   |         🟢         |           🟢           |      ⚫      |
| VPN - [Tailscale](https://tailscale.com/)                         |  🟢  |  ⚫   |         🟢         |           🟠           |      ⚫      |
| VPN - [WireGuard](https://www.wireguard.com/)                     |  ⚫  |  ⚫   |         ⚫         |           ⚫           |      ⚫      |
| Distributed clipboard registry                                    |  🟡  |  ⚫   |         🟡         |           🟡           |      ⚫      |
| GPG/YubiKey support                                               |  ⚫  |  ⚫   |         ⚫         |           ⚫           |      ⚫      |

Legend:

- 🟢 Completed
- 🟠 Partial Support
- 🟡 In Progress
- ⚫ Planned
- ⛔ Not Possible/Applicable
- N/A Not Applicable

### Feature Descriptions

- **System-level integration**: Ensures deep integration with the host operating
  system for optimal performance and functionality. Not applicable for
  standalone Home Manager use.
- **Secret management**: Utilizes sops-nix for secure handling of sensitive
  information across platforms, including standalone Home Manager
  configurations.
- **VPN solutions**: Implements Tailscale for secure networking, with WireGuard
  support planned for the future. Available in Home Manager configurations.
- **Distributed clipboard registry**: A work-in-progress feature for seamless
  clipboard sharing between devices, including Home Manager setups.
- **GPG/YubiKey support**: Planned security enhancements for robust
  authentication and encryption capabilities across all supported platforms.

## Installation

path/to/bootstrap' $ nix run .#deploy --
'github:geoffreygarrett/nix-on-droid/main' 'user@host:/path/to/bootstrap'

```shell
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

(Add installation instructions for each supported platform, including standalone
Home Manager use)

## Usage

(Provide usage examples and common commands for each deployment scenario,
including Home Manager)

## Key Components

1. **Home Manager Integration**

   - Standalone user environment management
   - Compatible with various Linux distributions and macOS

1. **System Integration**

   - NixOS: Native support
   - macOS: via [`nix-darwin`](https://github.com/LnL7/nix-darwin)
   - Android: via Nix-on-Droid (`aarch64-linux` only)
   - Mobile devices: Experimental support via Mobile NixOS

1. **Secret Management**

   - Powered by [`sops-nix`](https://github.com/Mic92/sops-nix)
   - Supported across all platforms, including standalone Home Manager use
   - Custom workaround implemented for Nix-on-Droid

1. **VPN Solutions**

   - Tailscale: Fully implemented on Home Manager and macOS, partial support on
     Nix-on-Droid
   - WireGuard: Planned for future implementation across all platforms

1. **Clipboard Management**

   - Distributed clipboard registry system (in progress)
   - Inspired by Neovim's registry clipboard system
   - Planned for all supported platforms, including Home Manager

1. **Security Enhancements**

   - GPG integration planned for all platforms
   - YubiKey support in roadmap for enhanced security across deployments

## Roadmap

### Short-term Goals

- Merge Nix-on-Droid sops-nix workaround upstream
- Complete distributed clipboard registry system
- Improve Tailscale support for Nix-on-Droid
- Implement WireGuard support

### Medium-term Goals

- Develop sops-nix.lib.darwinModules for improved macOS support
- Expand GPG functionality with YubiKey integration
- Enhance cross-platform compatibility for clipboard registry

### Long-term Goals

- Further integrate and stabilize Mobile NixOS support
- Explore iOS integration possibilities
- Continuous improvement of system-level integration across platforms
- Investigate support for additional Android architectures in Nix-on-Droid

## Contributing

We welcome contributions to the Nixus Device System project! If you're
interested in helping, please:

1. Fork the repository
1. Create a new branch for your feature or bug fix
1. Make your changes and commit them with clear, descriptive messages
1. Push your changes to your fork
1. Create a pull request with a detailed description of your changes

For more detailed contributing guidelines, please see our CONTRIBUTING.md file
(link to file).

## License

(Add your project's license information here)
