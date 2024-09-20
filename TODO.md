# TODO

- \[ \] picom window tiling on nixos

- \[x\] Fix multiline insert in visual block mode

  - Issue: `<S-I>` after entering visual block mode `<C-v>` only inserts at a
    single line
  - Reference:
    https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip

- \[ \] Ensure Neovim uses the same Zsh from Nix

  - Currently seems to be using an arbitrary `zsh`

- \[ \] Add dependency on gh module for Neovim Nix module

  - Implement via gh lua plugin

- \[x\] Add backup functionality to all switches

  - Should force backup any files in the way

- \[x\] Configure key-repeat for Ubuntu/Linux & NixOS

- \[ \] Implement CI integration for configuration screenshots

  - Purpose: Track evolution of configs over time

- \[x\] (Implied task) Install or update JetBrains Mono font

  - Download link:
    https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip

- \[ \] Change `deep ocean` theme style to the color assignments of Jetbrains,
  rather than vscode.

- \[ \] Add proper itnegration for nix-colors and sort out a consistent color
  scheming throughout my configuration.

- \[ \] Additionally for the color scheme, see if it's possible to hotswap color
  schemes throughout. [repo](https://github.com/Misterio77/nix-colors).

- \[ \] Spend some time learning `tmux-sessionator` and using it productively.
  [repo](https://github.com/jrmoulton/tmux-sessionizer).
