{ pkgs, lib, ... }:

let
  # Helper function to create a package definition
  mkPkg = pkg: bin: { inherit pkg bin; };

  # Define the available dependencies with their paths
  dependencies = {
    eza             = mkPkg pkgs.eza            "eza";
    bat             = mkPkg pkgs.bat            "bat";
    neovim          = mkPkg pkgs.neovim         "nvim";
    fd              = mkPkg pkgs.fd             "fd";
    ripgrep         = mkPkg pkgs.ripgrep        "rg";
    htop            = mkPkg pkgs.htop           "htop";
    duf             = mkPkg pkgs.duf            "duf";
    ncdu            = mkPkg pkgs.ncdu           "ncdu";
    prettyping      = mkPkg pkgs.prettyping     "prettyping";
    viddy           = mkPkg pkgs.viddy          "viddy";
    kubectl         = mkPkg pkgs.kubectl        "kubectl";
    podmanCompose   = mkPkg pkgs.podman-compose "podman-compose";
    busybox         = mkPkg pkgs.busybox        "busybox";
  };

  # Helper function to create an alias definition
  mkAlias = key: dependency: command: description: { inherit key dependency command description; };

  # Define aliases with their keys and additional commands, if any
  aliases = [
    (mkAlias "ls"       "eza"      "--icons --group-directories-first"  "List directory contents with icons and directories first.")
    (mkAlias "ll"       "eza"      "-alF --icons --group-directories-first" "List all files with detailed view.")
    (mkAlias "l"        "eza"      "-a --icons --group-directories-first" "List all files including hidden ones.")
    (mkAlias "tree"     "eza"      "--tree --icons"                     "List files in a tree view.")
    (mkAlias "cat"      "bat"      "--style=plain --paging=never"       "Concatenate and display files with syntax highlighting.")
    (mkAlias "nvim"     "neovim"   ""                                   "Launch Neovim.")
    (mkAlias "holdnvim" "neovim"   ""                                   "Alias for Neovim.")
    (mkAlias "n"        "neovim"   ""                                   "Alias for Neovim.")
    (mkAlias "less"     "bat"      ""                                   "View files with syntax highlighting.")
    (mkAlias "grep"     "ripgrep"  ""                                   "Search for patterns in files.")
    (mkAlias "find"     "fd"       ""                                   "Find files and directories.")
    (mkAlias "top"      "htop"     ""                                   "Display dynamic real-time information about running processes.")
    (mkAlias "df"       "duf"      ""                                   "Disk usage and space analyzer.")
    (mkAlias "du"       "ncdu"     ""                                   "Disk usage analyzer with an ncurses interface.")
    (mkAlias "ping"     "prettyping" ""                                 "Ping a host with pretty output.")
    (mkAlias "watch"    "viddy"    ""                                   "Monitor the output of a program every few seconds.")
    (mkAlias "sudoe"    null       "sudo -E -s"                         "Run a command with elevated privileges while preserving the environment.")
    (mkAlias "tb"       null       "nc termbin.com 9999"                "Paste text to termbin.com.")
    (mkAlias "pingt"    null       "ping -c 5 google.com"               "Ping Google 5 times.")
    (mkAlias "pingd"    null       "ping -c 5 8.8.8.8"                  "Ping DNS 5 times.")
    (mkAlias "gitlog"   null       "git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'" "Show git commit history as a graph.")
    (mkAlias "gitlines" null       "git ls-files | xargs wc -l"         "Count lines of code in the repository.")
    (mkAlias "dirsize"  null       "du -sh $PWD/*"                      "Show the size of directories in the current path.")
    (mkAlias "k"        "kubectl"  ""                                   "Alias for kubectl.")
    (mkAlias "pc"       "podmanCompose" ""                              "Alias for podman-compose.")
    (mkAlias "kpods"    "kubectl"  "get pods --all-namespaces | grep -v 'kube-system'" "Get all Kubernetes pods excluding the kube-system namespace.")
    (mkAlias "kbox"     "kubectl"  "run temp-pod --rm -i --tty --image=${dependencies.busybox.pkg}/bin/busybox -- /bin/sh" "Run a temporary pod in Kubernetes with a Busybox shell.")
  ];

  # Helper function to generate the command for an alias
  getAliasCommand = alias:
    if alias.dependency != null
    then "${lib.getBin dependencies.${alias.dependency}.pkg}/bin/${dependencies.${alias.dependency}.bin} ${alias.command}"
    else alias.command;


  # Updated shellAliases with modified alias-info function
  shellAliases = builtins.listToAttrs (map (alias: { name = alias.key; value = getAliasCommand alias; }) aliases)
    // {
      "alias-info" = ''
        alias_info() {
          if [ "$1" = "-v" ]; then
            printf "\033[1;36mDetailed Alias Information:\033[0m\n"
            ${builtins.concatStringsSep "\n" (map (a: ''
              printf "\033[1;34m%s\033[0m\n" "${a.key}"
              printf "  \033[1;32mDescription:\033[0m %s\n" "${a.description}"
              printf "  \033[1;33mCommand:\033[0m %s\n\n" "${getAliasCommand a}"
            '') aliases)}
          else
            printf "\033[1;36mAvailable Aliases:\033[0m\n"
            ${builtins.concatStringsSep "\n" (map (a: ''
              printf "\033[1;34m%-15s\033[0m \033[1;32m%s\033[0m\n" "${a.key}" "${a.description}"
            '') aliases)}
          fi
        }
        alias_info "$@"
      '';
    };

in
{
  shellAliases = shellAliases;
}