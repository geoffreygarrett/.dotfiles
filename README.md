# Cross-Platform Terminal Setup

A cross-platform, one-click setup for a consistent terminal environment with Alacritty, Zellij, and Neovim.

## Overview

This repository contains configuration files and setup scripts for a unified terminal experience across Windows, macOS, and Linux. It sets up:

- [Alacritty](https://github.com/alacritty/alacritty): A fast, cross-platform, OpenGL terminal emulator
- [Zellij](https://github.com/zellij-org/zellij): A terminal workspace with batteries included
- [Neovim](https://neovim.io/): Hyper extensible Vim-based text editor

## Features

- Works on Windows, macOS, and Linux
- One-click installation process
- Version-controlled configurations
- Easy to update and sync across multiple machines

## Prerequisites

- Git
- Bash (Git Bash on Windows)
- Package manager:
    - apt (Linux)
    - [Homebrew](https://brew.sh/) (macOS)
    - [Chocolatey](https://chocolatey.org/) (Windows)

## Installation

### One-Click Setup

1. Download the `one-click-setup.sh` script from this repository.
2. Make it executable:
   ```
   chmod +x one-click-setup.sh
   ```
3. Run the script:
   ```
   ./one-click-setup.sh
   ```

This script will clone the repository, run the setup script, and configure your terminal environment.

### Manual Setup

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/cross-platform-terminal-setup.git
   ```
2. Navigate to the repository directory:
   ```
   cd cross-platform-terminal-setup
   ```
3. Run the setup script:
   ```
   ./setup.sh
   ```

## Configuration

### Alacritty

The Alacritty configuration file is located at `alacritty/alacritty.yml`. Modify this file to customize your Alacritty settings.

### Zellij

The Zellij configuration file is located at `zellij/config.yaml`. Adjust this file to change your Zellij layout and settings.

### Neovim

The Neovim configuration is in `nvim/init.vim`. Edit this file to customize your Neovim setup, including plugins and keybindings.

## Updating

To update your configuration:

1. Navigate to the repository directory.
2. Pull the latest changes:
   ```
   git pull
   ```
3. Run the setup script again:
   ```
   ./setup.sh
   ```

## Contributing

Contributions are welcome! Feel free to submit a Pull Request.

## License

This project is open source and available under the [MIT License](LICENSE).

## Support

If you encounter any problems or have any questions, please open an issue in this repository.