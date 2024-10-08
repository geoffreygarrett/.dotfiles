{ pkgs, ... }:
{
  force = true;
  engines = {
    "Rust Docs" = {
      urls = [
        {
          template = "https://doc.rust-lang.org/std/?search={searchTerms}";
        }
      ];
      iconUpdateURL = "https://www.rust-lang.org/favicon.ico";
      updateInterval = 24 * 60 * 60 * 1000;
      definedAliases = [ "@rust" ];
    };
    "GitHub Code" = {
      urls = [
        {
          template = "https://github.com/search?q={searchTerms}&type=code";
        }
      ];
      iconUpdateURL = "https://github.com/favicon.ico";
      updateInterval = 24 * 60 * 60 * 1000;
      definedAliases = [ "@ghc" ];
    };
    "Stack Overflow" = {
      urls = [
        {
          template = "https://stackoverflow.com/search?q={searchTerms}";
        }
      ];
      iconUpdateURL = "https://cdn.sstatic.net/Sites/stackoverflow/Img/favicon.ico";
      updateInterval = 24 * 60 * 60 * 1000;
      definedAliases = [ "@so" ];
    };
    "arXiv" = {
      urls = [
        {
          template = "https://arxiv.org/search/?query={searchTerms}&searchtype=all";
        }
      ];
      iconUpdateURL = "https://static.arxiv.org/static/browse/0.3.2.8/images/icons/favicon.ico";
      updateInterval = 24 * 60 * 60 * 1000;
      definedAliases = [ "@arx" ];
    };
    "Google Scholar" = {
      urls = [
        {
          template = "https://scholar.google.com/scholar?q={searchTerms}";
        }
      ];
      iconUpdateURL = "https://scholar.google.com/favicon.ico";
      updateInterval = 24 * 60 * 60 * 1000;
      definedAliases = [ "@gs" ];
    };
    "Anaconda Packages" = {
      iconUpdateURL = "https://www.google.com/s2/favicons?domain=anaconda.org";
      updateInterval = 24 * 60 * 60 * 1000; # every day
      urls = [
        {
          template = "https://anaconda.org/search";
          params = [
            {
              name = "q";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      definedAliases = [ "@ap" ];
    };
    "NixOS Wiki" = {
      urls = [ { template = "https://nixos.wiki/index.php?search={searchTerms}"; } ];
      iconUpdateURL = "https://nixos.wiki/favicon.png";
      updateInterval = 24 * 60 * 60 * 1000; # every day
      definedAliases = [ "@nw" ];
    };
    "Nix Packages" = {
      urls = [
        {
          template = "https://search.nixos.org/packages";
          params = [
            {
              name = "channel";
              value = "unstable";
            }
            {
              name = "type";
              value = "packages";
            }
            {
              name = "query";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      definedAliases = [ "@np" ];
    };
  };
}
