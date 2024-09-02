{ lib, pkgs }:

rec {
  loadConfigFiles = dir: builtins.listToAttrs (
    map
      (file: {
        name = ".config/" + lib.removePrefix (toString dir + "/") (toString file);
        value = { source = file; };
      })
      (pkgs.lib.filesystem.listFilesRecursive dir)
  );

  loadConfigs = configDir: loadConfigFiles configDir;
}