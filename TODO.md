# TODO

- [ ] picom window tiling on nixos

- [x] Fix multiline insert in visual block mode
  - Issue: `<S-I>` after entering visual block mode `<C-v>` only inserts at a single line
  - Reference: https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip

- [ ] Ensure Neovim uses the same Zsh from Nix
  - Currently seems to be using an arbitrary `zsh`

- [ ] Add dependency on gh module for Neovim Nix module
  - Implement via gh lua plugin

- [x] Add backup functionality to all switches
  - Should force backup any files in the way

- [x] Configure key-repeat for Ubuntu/Linux & NixOS

- [ ] Implement CI integration for configuration screenshots
  - Purpose: Track evolution of configs over time

- [x] (Implied task) Install or update JetBrains Mono font
  - Download link: https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip
