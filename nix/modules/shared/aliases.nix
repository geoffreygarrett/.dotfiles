{
  pkgs,
  ...
}:

{
  aliases.enable = true;
  aliases.aliases = {
    sshkey = {
      command = ''
        ID="$HOME/.ssh/id_ed25519"
        if [ -f "$ID.pub" ]; then
          cat "$ID.pub"
        else
          ssh-keygen -t ed25519 -f "$ID" -N "" && cat "$ID.pub"
        fi
      '';
      description = "Generate (if needed) and display local SSH public key";
      tags = [
        "ssh"
        "zsh"
        "fish"
        "bash"
        "nu"
      ];
    };
    remote-sshkey = {
      command = ''
        if [ $# -eq 0 ]; then
          echo "Usage: remote-sshkey user@host"
          return 1
        fi
        user_host="$1"
        ssh -o BatchMode=yes "$user_host" 'ID="$HOME/.ssh/id_ed25519"; if [ -f "$ID.pub" ]; then cat "$ID.pub"; else ssh-keygen -t ed25519 -f "$ID" -N "" && cat "$ID.pub"; fi'
      '';
      description = "Generate (if needed) and display remote SSH public key";
      tags = [
        "ssh"
        "zsh"
        "fish"
        "bash"
        "nu"
      ];
    };
    fml = {
      command = "git log --since=\"yesterday\" --pretty=format:\"%h - %an: %s\" && echo \"\\nTODOs:\" && grep -rn \"TODO\" .";
      description = "Show recent commits and TODOs in the project";
      tags = [
        "git"
        "productivity"
        "code-review"
        "zsh"
        "fish"
        "nu"
      ];
    };

    yolo = {
      command = "git push origin master --force --no-verify";
      description = "Force push to master branch";
      tags = [
        "git"
        "zsh"
        "fish"
        "nu"
      ];
    };

    # Nixus/flake related
    cdf = {
      command = "cd ~/.dotfiles";
      description = "Enter directory with dotfiles flake";
      tags = [
        "zsh"
        "nu"
        "navigation"
      ];
    };

    # File and Directory Operations
    ls = {
      command = "${pkgs.eza}/bin/eza --icons --group-directories-first";
      description = "List directory contents with icons and directories first.";
      tags = [
        "file"
        "list"
        "zsh"
        "fish"
        "nu"
      ];
    };

    ll = {
      command = "${pkgs.eza}/bin/eza -alF --icons --group-directories-first";
      description = "List all files with detailed view.";
      tags = [
        "file"
        "list"
        "zsh"
        "fish"
        "nu"
      ];
    };

    l = {
      command = "${pkgs.eza}/bin/eza -a --icons --group-directories-first";
      description = "List all files including hidden ones.";
      tags = [
        "file"
        "list"
        "zsh"
        "fish"
        "nu"
      ];
    };

    tree = {
      command = "${pkgs.eza}/bin/eza --tree --icons";
      description = "List files in a tree view.";
      tags = [
        "file"
        "list"
        "zsh"
        "fish"
        "nu"
      ];
    };

    cat = {
      command = "${pkgs.bat}/bin/bat --style=plain --paging=never";
      description = "Concatenate and display files with syntax highlighting.";
      tags = [
        "file"
        "view"
        "zsh"
        "fish"
        "nu"
      ];
    };

    less = {
      command = "${pkgs.bat}/bin/bat";
      description = "View files with syntax highlighting.";
      tags = [
        "file"
        "view"
        "zsh"
        "fish"
        "nu"
      ];
    };

    find = {
      command = "${pkgs.fd}/bin/fd";
      description = "Find files and directories.";
      tags = [
        "search"
        "zsh"
        "fish"
        "nu"
      ];
    };

    dirsize = {
      command = "du -sh $PWD/*";
      description = "Show the size of directories in the current path.";
      tags = [
        "system"
        "disk"
        "zsh"
        "fish"
        "nu"
      ];
    };

    holdnvim = {
      command = "nvim";
      description = "Alias for Neovim.";
      tags = [
        "editor"
        "zsh"
        "fish"
        "nu"
      ];
    };

    n = {
      command = "nvim";
      description = "Alias for Neovim.";
      tags = [
        "editor"
        "zsh"
        "fish"
        "nu"
      ];
    };

    # System Information and Management
    neofetch = {
      command = "${pkgs.neofetch}/bin/neofetch";
      description = "Show system information.";
      tags = [
        "system"
        "info"
        "zsh"
        "nu"
      ];
    };

    top = {
      command = "${pkgs.htop}/bin/htop";
      description = "Display dynamic real-time information about running processes.";
      tags = [
        "system"
        "monitor"
        "zsh"
        "nu"
      ];
    };

    df = {
      command = "${pkgs.duf}/bin/duf";
      description = "Disk usage and space analyzer.";
      tags = [
        "system"
        "disk"
        "zsh"
        "fish"
        "nu"
      ];
    };

    du = {
      command = "${pkgs.ncdu}/bin/ncdu";
      description = "Disk usage analyzer with an ncurses interface.";
      tags = [
        "system"
        "disk"
        "zsh"
        "fish"
        "nu"
      ];
    };

    watch = {
      command = "${pkgs.viddy}/bin/viddy";
      description = "Monitor the output of a program every few seconds.";
      tags = [
        "system"
        "monitor"
        "zsh"
        "fish"
        "nu"
      ];
    };

    sudoe = {
      command = "sudo -E -s";
      description = "Run a command with elevated privileges while preserving the environment.";
      tags = [
        "system"
        "admin"
        "zsh"
        "fish"
        "nu"
      ];
    };

    # Networking
    ping = {
      command = "${pkgs.prettyping}/bin/prettyping";
      description = "Ping a host with pretty output.";
      tags = [
        "network"
        "zsh"
        "fish"
        "nu"
      ];
    };

    tb = {
      command = "nc termbin.com 9999";
      description = "Paste text to termbin.com.";
      tags = [
        "network"
        "share"
        "zsh"
        "fish"
        "nu"
      ];
    };

    pingt = {
      command = "ping -c 5 google.com";
      description = "Ping Google 5 times.";
      tags = [
        "network"
        "zsh"
        "fish"
        "nu"
      ];
    };

    pingd = {
      command = "ping -c 5 8.8.8.8";
      description = "Ping DNS 5 times.";
      tags = [
        "network"
        "zsh"
        "fish"
        "nu"
      ];
    };

    localip = {
      command = "${pkgs.writeShellScriptBin "localip-script" ''
        #!/usr/bin/env bash
        if [[ "$(uname)" == "Darwin" ]]; then
            ifconfig | grep "inet " | grep -v 127.0.0.1 | cut -d\  -f2
        elif [[ -x "$(command -v hostname)" && "$(hostnamectl | grep "Operating System")" == *"Ubuntu"* ]]; then
            hostname -i | awk '{print $3}'
        elif [[ -x "$(command -v hostname)" && "$(hostnamectl | grep "Operating System")" == *"Debian"* ]]; then
            hostname -i
        elif [[ -x "/sbin/ifconfig" ]]; then
            /sbin/ifconfig eth0 | grep "inet addr" | cut -d: -f2 | awk '{print $1}'
        else
            echo "Unable to determine local IP"
        fi
      ''}/bin/localip-script";
      description = "Show local IP address";
      tags = [
        "network"
        "zsh"
        "nu"
      ];
    };

    # Git Operations
    gitlog = {
      command = "git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'";
      description = "Show git commit history as a graph.";
      tags = [
        "git"
        "zsh"
        "fish"
        "nu"
      ];
    };

    gitlines = {
      command = "git ls-files | xargs wc -l";
      description = "Count lines of code in the repository.";
      tags = [
        "git"
        "zsh"
        "fish"
        "nu"
      ];
    };

    gitstatusall = {
      command = "\\find . -name .git -type d -execdir git status \\;";
      description = "Show the status of all files in the repository.";
      tags = [
        "git"
        "zsh"
        "fish"
        "nu"
      ];
    };

    # Container and Orchestration
    k = {
      command = "${pkgs.kubectl}/bin/kubectl";
      description = "Alias for kubectl.";
      tags = [
        "kubernetes"
        "zsh"
        "fish"
        "nu"
      ];
    };

    pc = {
      command = "${pkgs.podman-compose}/bin/podman-compose";
      description = "Alias for podman-compose.";
      tags = [
        "container"
        "zsh"
        "fish"
        "nu"
      ];
    };

    kpods = {
      command = "${pkgs.kubectl}/bin/kubectl get pods --all-namespaces | grep -v 'kube-system'";
      description = "Get all Kubernetes pods excluding the kube-system namespace.";
      tags = [
        "kubernetes"
        "zsh"
        "fish"
        "nu"
      ];
    };

    # Miscellaneous
    # NOTE: Following was causing nix-shell -p to break with syntax errors.
    grep = {
      command = "${pkgs.ripgrep}/bin/rg";
      description = "Search for patterns in files.";
      tags = [
        "search"
        "zsh"
        "fish"
        "nu"
      ];
    };

    viu = {
      command = "${pkgs.viu}/bin/viu";
      description = "Alias for viu.";
      tags = [
        "image"
        "view"
        "zsh"
        "fish"
        "nu"
      ];
    };

    prb = {
      command = "cat ~/Downloads/out2.xlsx | from xlsx";
      description = "Show PRBs";
      tags = [ "nu" ];
    };

    delete-images = {
      command = "${pkgs.writeShellScriptBin "delete-images-script" ''
        #!/usr/bin/env bash
        delete_image() {
          if rm -i "$1"; then
            echo "Deleted: $1"
          else
            echo "Deletion cancelled for: $1"
          fi
        }
        export -f delete_image

        if [ $# -eq 0 ]; then
          echo "Please provide a directory path as an argument."
          exit 1
        fi

        ${pkgs.fd}/bin/fd --extension jpg --extension png --base-directory "$1" | \
        ${pkgs.fzf}/bin/fzf --preview "${pkgs.viu}/bin/viu --width 80 \"$1/{}\""  \
          --preview-window=right:81:wrap \
          --bind "enter:execute(delete_image \"$1/{}\")+reload(${pkgs.fd}/bin/fd --extension jpg --extension png --base-directory \"$1\")"
      ''}/bin/delete-images-script";
      description = "Interactive image deletion using fzf and viu";
      tags = [
        "utilities"
        "images"
        "zsh"
      ];
    };

    # New enhanced CLI tool aliases
    fzf = {
      command = "${pkgs.fzf}/bin/fzf";
      description = "Fuzzy finder for command-line";
      tags = [
        "search"
        "productivity"
        "zsh"
        "fish"
        "nu"
      ];
    };

    jq = {
      command = "${pkgs.jq}/bin/jq";
      description = "Command-line JSON processor";
      tags = [
        "json"
        "data"
        "zsh"
        "fish"
        "nu"
      ];
    };

    tldr = {
      command = "${pkgs.tldr}/bin/tldr";
      description = "Simplified and community-driven man pages";
      tags = [
        "documentation"
        "help"
        "zsh"
        "fish"
        "nu"
      ];
    };

    bench = {
      command = "${pkgs.hyperfine}/bin/hyperfine";
      description = "Command-line benchmarking tool";
      tags = [
        "performance"
        "benchmark"
        "zsh"
        "fish"
        "nu"
      ];
    };

    git-diff = {
      command = "${pkgs.delta}/bin/delta";
      description = "Syntax-highlighting pager for git, diff, and grep output";
      tags = [
        "git"
        "diff"
        "zsh"
        "fish"
        "nu"
      ];
    };

    fpp = {
      command = "${pkgs.fpp}/bin/fpp";
      description = "CLI tool that lets you select files from command output";
      tags = [
        "file"
        "productivity"
        "zsh"
        "fish"
        "nu"
      ];
    };

    z = {
      command = "${pkgs.zoxide}/bin/zoxide";
      description = "A smarter cd command with interactive selection";
      tags = [
        "navigation"
        "productivity"
        "zsh"
        "fish"
        "nu"
      ];
    };

    csv = {
      command = "${pkgs.xsv}/bin/xsv";
      description = "A fast CSV command-line toolkit";
      tags = [
        "csv"
        "data"
        "zsh"
        "fish"
        "nu"
      ];
    };

    fm = {
      command = "${pkgs.nnn}/bin/nnn -e";
      description = "Full-featured terminal file manager";
      tags = [
        "file"
        "manager"
        "zsh"
        "fish"
        "nu"
      ];
    };

    tldrs = {
      command = "${pkgs.tealdeer}/bin/tldr";
      description = "Fast tldr client written in Rust";
      tags = [
        "documentation"
        "help"
        "zsh"
        "fish"
        "nu"
      ];
    };

    windows = {
      command = "systemctl reboot --boot-loader-entry=auto-windows";
      description = "Reboot into Windows in dual-boot";
      tags = [
        "system"
        "zsh"
        "fish"
        "nu"
      ];
    };
  };
}
