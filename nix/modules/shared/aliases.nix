{
  self,
  config,
  inputs,
  pkgs,
  user,
  ...
}:

{
  aliases.enable = true;
  aliases.aliases = {

    #    # New RGB control aliases
    #    rgb-off = {
    #      command = "${pkgs.writeShellScriptBin "rgb-off-script" ''
    #        #!/bin/sh
    #        NUM_DEVICES=$(${pkgs.openrgb}/bin/openrgb --noautoconnect --list-devices | grep -E '^[0-9]+: ' | wc -l)
    #
    #        for i in $(seq 0 $(($NUM_DEVICES - 1))); do
    #          ${pkgs.openrgb}/bin/openrgb --noautoconnect --device $i --mode static --color 000000
    #        done
    #      ''}/bin/rgb-off-script";
    #      description = "Turn off all RGB lighting";
    #      tags = [
    #        "system"
    #        "rgb"
    #        "zsh"
    #        "bash"
    #        "fish"
    #        "nu"
    #      ];
    #    };
    #
    #    rgb-on = {
    #      command = "${pkgs.writeShellScriptBin "rgb-on-script" ''
    #        #!/bin/sh
    #        NUM_DEVICES=$(${pkgs.openrgb}/bin/openrgb --noautoconnect --list-devices | grep -E '^[0-9]+: ' | wc -l)
    #
    #        for i in $(seq 0 $(($NUM_DEVICES - 1))); do
    #          ${pkgs.openrgb}/bin/openrgb --noautoconnect --device $i --mode static --color FFFFFF
    #        done
    #      ''}/bin/rgb-on-script";
    #      description = "Turn on all RGB lighting (white color)";
    #      tags = [
    #        "system"
    #        "rgb"
    #        "zsh"
    #        "bash"
    #        "fish"
    #        "nu"
    #      ];
    #    };
    #
    # Nixus/flake related
    cdf = {
      command = "cd ~/.dotfiles";
      description = "Enter directory with dotfiles flake";
      tags = [
        "zsh"
        "nu"
        "bash"
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
        "bash"
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
        "bash"
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
        "bash"
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
        "bash"
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
        "bash"
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
        "bash"
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
        "bash"
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
        "bash"
        "fish"
        "nu"
      ];
    };

   # # Text Editing and Viewing
   # nvim = {
   #   command = "${pkgs.neovim-unwrapped}/bin/nvim";
   #   description = "Launch Neovim.";
   #   tags = [
   #     "editor"
   #     "zsh"
   #     "bash"
   #     "fish"
   #     "nu"
   #   ];
   # };

    holdnvim = {
      command = "nvim";
      description = "Alias for Neovim.";
      tags = [
        "editor"
        "zsh"
        "bash"
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
        "bash"
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
        "bash"
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
        "bash"
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
        "bash"
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
        "bash"
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
        "bash"
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
        "bash"
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
        "bash"
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
        "bash"
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
        "bash"
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
        "bash"
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
        "bash"
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
        "bash"
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
        "bash"
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
        "bash"
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
        "bash"
        "fish"
        "nu"
      ];
    };

    # Miscellaneous
    grep = {
      command = "${pkgs.ripgrep}/bin/rg";
      description = "Search for patterns in files.";
      tags = [
        "search"
        "zsh"
        "bash"
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
        "bash"
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
        "bash"
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
        "bash"
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
        "bash"
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
        "bash"
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
        "bash"
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
        "bash"
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
        "bash"
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
        "bash"
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
        "bash"
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
        "bash"
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
        "bash"
        "fish"
        "nu"
      ];
    };

    windows = {
      command = "systemctl reboot --boot-loader-entry=\"Windows Boot Manager (on /dev/nvme0n1p1)\"";
      description = "Reboot into Windows in dual-boot";
      tags = [
        "system"
        "zsh"
        "bash"
        "fish"
        "nu"
      ];
    };
  };
}
