{ pkgs, lib, ... }:

let
  # Define the mkPkg function
  mkPkg = pkg: bin: { inherit pkg bin; };

  # Helper function to create an alias definition with shell-specific settings
  mkAlias = key: dependency: command: description: shells: { inherit key dependency command description shells; };

  # Define the available dependencies with their paths
  dependencies = {
    eza = mkPkg pkgs.eza "eza";
    feh = mkPkg pkgs.feh "feh";
    bat = mkPkg pkgs.bat "bat";
    neovim = mkPkg pkgs.neovim "nvim";
    fd = mkPkg pkgs.fd "fd";
    ripgrep = mkPkg pkgs.ripgrep "rg";
    htop = mkPkg pkgs.htop "htop";
    duf = mkPkg pkgs.duf "duf";
    ncdu = mkPkg pkgs.ncdu "ncdu";
    prettyping = mkPkg pkgs.prettyping "prettyping";
    viddy = mkPkg pkgs.viddy "viddy";
    kubectl = mkPkg pkgs.kubectl "kubectl";
    podmanCompose = mkPkg pkgs.podman-compose "podman-compose";
    viu = mkPkg pkgs.viu "viu";
    neofetch = mkPkg pkgs.neofetch "neofetch";
    # busybox         = mkPkg pkgs.busybox        "busybox";
  };
  #    dependencies.viddy.bin = "${dependencies.viddy.bin}/bin/viddy";
  # Define shells
  shells = {
    zsh = true;
    bash = false;
    fish = false;
    nu = false;
  };

  # Define aliases with their keys, additional commands, and shell-specific settings
  aliases = [
    (mkAlias "neofetch" "neofetch" "" "Show system information." { zsh = true; nu = true; bash = false; fish = false; })
    (mkAlias "ls" "eza" "--icons --group-directories-first" "List directory contents with icons and directories first." shells)
    (mkAlias "ll" "eza" "-alF --icons --group-directories-first" "List all files with detailed view." shells)
    (mkAlias "l" "eza" "-a --icons --group-directories-first" "List all files including hidden ones." shells)
    (mkAlias "tree" "eza" "--tree --icons" "List files in a tree view." shells)
    (mkAlias "cat" "bat" "--style=plain --paging=never" "Concatenate and display files with syntax highlighting." shells)
    (mkAlias "nvim" "neovim" "" "Launch Neovim." shells)
    (mkAlias "holdnvim" "neovim" "" "Alias for Neovim." shells)
    (mkAlias "n" "neovim" "" "Alias for Neovim." shells)
    (mkAlias "less" "bat" "" "View files with syntax highlighting." shells)
    (mkAlias "grep" "ripgrep" "" "Search for patterns in files." shells)
    (mkAlias "find" "fd" "" "Find files and directories." shells)
    (mkAlias "top" "htop" "" "Display dynamic real-time information about running processes." { zsh = true; nu = true; bash = false; fish = false; })
    (mkAlias "df" "duf" "" "Disk usage and space analyzer." shells)
    (mkAlias "du" "ncdu" "" "Disk usage analyzer with an ncurses interface." shells)
    (mkAlias "ping" "prettyping" "" "Ping a host with pretty output." shells)
    (mkAlias "watch" "viddy" "" "Monitor the output of a program every few seconds." shells)
    (mkAlias "sudoe" null "sudo -E -s" "Run a command with elevated privileges while preserving the environment." shells)
    (mkAlias "tb" null "nc termbin.com 9999" "Paste text to termbin.com." shells)
    (mkAlias "pingt" null "ping -c 5 google.com" "Ping Google 5 times." shells)
    (mkAlias "pingd" null "ping -c 5 8.8.8.8" "Ping DNS 5 times." shells)
    (mkAlias "gitlog" null "git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'" "Show git commit history as a graph." shells)
    (mkAlias "gitlines" null "git ls-files | xargs wc -l" "Count lines of code in the repository." shells)
    (mkAlias "dirsize" null "du -sh $PWD/*" "Show the size of directories in the current path." shells)
    (mkAlias "k" "kubectl" "" "Alias for kubectl." shells)
    (mkAlias "pc" "podmanCompose" "" "Alias for podman-compose." shells)
    (mkAlias "viu" "${dependencies.viu.bin}" "" "Alias for viu." shells)
    (mkAlias "kpods" "kubectl" "get pods --all-namespaces | grep -v 'kube-system'" "Get all Kubernetes pods excluding the kube-system namespace." shells)
    #(mkAlias "kbox"     "kubectl"  "run temp-pod --rm -i --tty --image=${dependencies.busybox.pkg}/bin/busybox -- /bin/sh" "Run a temporary pod in Kubernetes with a Busybox shell." shells)
    (mkAlias "rh1" null "nix run .#homeConfigurations.$(whoami)@$(hostname).activationPackage && exec zsh" "Apply home configuration changes and restart shell." shells)
    (mkAlias "rh" null "${pkgs.bash}/bin/bash ${./rh.sh}" "Apply home configuration changes and restart shell." { zsh = true; nu = true; bash = false; fish = false; })
    (mkAlias "prb" null "cat ~/Downloads/out2.xlsx | from xlsx" "Show PRBs" { zsh = false; nu = true; bash = false; fish = false; })
    (mkAlias "delete-images" null ''
      alias delete-images='f() {
        delete_image() {
          if rm -i "$1"; then
            echo "Deleted: $1"
          else
            echo "Deletion cancelled for: $1"
          fi
        }
        export -f delete_image
        fd --extension jpg --extension png --base-directory "$1" | \
        fzf --preview "${dependencies.viu.bin} --width 80 \"$1/{}\""  \
            --preview-window=right:81:wrap \
            --bind "enter:execute(delete_image \"$1/{}\")+reload(fd --extension jpg --extension png --base-directory \"{}\")"
      }; f'
    '' "Delete images interactively."
      shells)
  ];

  # Helper function to generate the command for an alias
  getAliasCommand = alias:
    if alias.dependency != null
    then "${lib.getBin dependencies.${alias.dependency}.pkg}/bin/${dependencies.${alias.dependency}.bin} ${alias.command}"
    else alias.command;

  # Function to filter aliases by shell
  filterAliasesByShell = shell: builtins.filter (alias: alias.shells.${shell} or false) aliases;

  # Generate shellAliases for a specific shell
  generateShellAliases = shell:
    let
      filteredAliases = filterAliasesByShell shell;
      bashLikeAliasInfo = ''
        alias_info() {
          if [ "$1" = "-v" ]; then
            echo "Detailed Alias Information:"
            ${builtins.concatStringsSep "\n" (map (a: ''
              echo "${a.key}"
              echo "  Description: ${a.description}"
              echo "  Command: ${getAliasCommand a}"
              echo ""
            '') filteredAliases)}
          else
            echo "Available Aliases:"
            ${builtins.concatStringsSep "\n" (map (a: ''
              printf "%-15s %s\n" "${a.key}" "${a.description}"
            '') filteredAliases)}
          fi
        }
      '';
    in
    builtins.listToAttrs (map (alias: { name = alias.key; value = getAliasCommand alias; }) filteredAliases)
    // (if shell == "nu" then { } else { "alias-info" = bashLikeAliasInfo; });

in
{
  shellAliases = {
    zsh = generateShellAliases "zsh";
    bash = generateShellAliases "bash";
    fish = generateShellAliases "fish";
    nu = generateShellAliases "nu";
  };
}
