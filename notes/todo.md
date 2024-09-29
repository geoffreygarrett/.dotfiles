- \[ \] Figure out why multiline insert doesnt work `<S-I>` after entering
  visual block mode `<C-v>`. Currently it just inserts at a single line.

  https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip

- \[ \] Configure nvim such that it uses the same zsh from nix. Currently it
  looks like it's just using some arbitrary `zsh`.:w!:

- \[ \] neovim nix module should have a dependency on gh module via gh lua
  plugin\]

- \[ \] Add backup to all switches, to force backup any files in the way

- \[ \] Key-repeat for ubuntu/linux & NixOS

- \[ \] CI intgeration for screenshotting configs for seeing it's evolution over
  time.

- `nix run ".#switch" --show-trace --update-input nixus`

- `nix build ".#nixosConfigurations.mariner-1.config.system.build.sdImage" --show-trace --out-link result-mariner-1`

- `# ssh geoffrey@192.168.68.121 '[ -f ~/.ssh/id_ed25519.pub ] && cat ~/.ssh/id_ed25519.pub || (ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -q && cat ~/.ssh/id_ed25519.pub)' | ssh-to-age`

- `ssh geoffrey@cassini 'cat ~/.ssh/id_ed25519.pub || (ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -q && cat ~/.ssh/id_ed25519.pub)'`
