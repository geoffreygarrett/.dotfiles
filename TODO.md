# TOD# Organized TODO List and Useful Commands

## Neovim Configuration

- [x] Fix multiline insert in visual block mode
  - Issue: `<S-I>` after entering visual block mode `<C-v>` only inserts at a
    single line
  - Reference:
    [JetBrainsMono Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip)
- [ ] Ensure Neovim uses the same Zsh from Nix
  - Currently seems to be using an arbitrary `zsh`
- [ ] Add dependency on gh module for Neovim Nix module
  - Implement via gh lua plugin

## System Configuration

- [x] Configure picom window tiling on NixOS
- [x] Add backup functionality to all switches
  - Should force backup any files in the way
- [x] Configure key-repeat for Ubuntu/Linux & NixOS

## CI and Monitoring

- [ ] Implement CI integration for configuration screenshots
  - Purpose: Track evolution of configs over time

## Theming and Aesthetics

- [x] (Implied task) Install or update JetBrains Mono font
- [ ] Change `deep ocean` theme style to the color assignments of Jetbrains,
      rather than vscode
- [ ] Add proper integration for nix-colors and sort out a consistent color
      scheming throughout configuration
- [ ] Investigate possibility of hotswapping color schemes
  - Reference: [nix-colors repo](https://github.com/Misterio77/nix-colors)

## Productivity Tools

- [ ] Spend time learning and using `tmux-sessionator` productively
  - Reference:
    [tmux-sessionizer repo](https://github.com/jrmoulton/tmux-sessionizer)

## Useful Commands

```bash
# Update and switch Nix configuration
nix run ".#switch" --show-trace --update-input nixus

# Build NixOS SD image for Mariner-1
nix build ".#nixosConfigurations.mariner-1.config.system.build.sdImage" --show-trace --out-link result-mariner-1

# Generate and fetch SSH public key, then convert to age format
ssh geoffrey@192.168.68.121 '[ -f ~/.ssh/id_ed25519.pub ] && cat ~/.ssh/id_ed25519.pub || (ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -q && cat ~/.ssh/id_ed25519.pub)' | ssh-to-age

# Generate and fetch SSH public key from Cassini
ssh geoffrey@cassini 'cat ~/.ssh/id_ed25519.pub || (ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -q && cat ~/.ssh/id_ed25519.pub)'
```

## Completed Tasks

- [x] Fix multiline insert in visual block mode
- [x] Configure picom window tiling on NixOS
- [x] Add backup functionality to all switches
- [x] Configure key-repeat for Ubuntu/Linux & NixOS
- [x] Install or update JetBrains Mono font
