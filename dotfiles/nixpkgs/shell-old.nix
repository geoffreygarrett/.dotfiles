let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-24.05";
  pkgs = import nixpkgs { config = {}; overlays = []; };
in

pkgs.mkShell {
  # Packages to include in the environment
  packages = with pkgs; [
    cowsay
    lolcat
    figlet
    neofetch
    starship
    fortune
    htop
  ];

  # Customize the shell experience with a cool welcome message
  shellHook = ''
    # Ensure we're using the correct shell
    if [ -n "$ZSH_VERSION" ]; then
      # If already in zsh, just continue
      eval "$(starship init zsh)"
    elif [ -n "$BASH_VERSION" ]; then
      # If in bash, initialize starship for bash
      eval "$(starship init bash)"
    else
      echo "Unsupported shell. Please use bash or zsh."
    fi

    # Print a cool welcome message
#    echo "Welcome to the coolest shell environment!" | cowsay | lolcat
#    echo "Remember to have fun while you code!" | figlet | lolcat

    # Display a random fortune
    fortune | cowsay -f dragon | lolcat

    # Show system information
    neofetch

    # Custom Aliases
    alias cls="clear"
    alias sysmon="htop"
    alias inspire="fortune | cowsay -f tux | lolcat"
  '';
}
