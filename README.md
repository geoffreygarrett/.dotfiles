# `nixus-core`

![nix](./nix-flake-logo.png "Nixus")

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


