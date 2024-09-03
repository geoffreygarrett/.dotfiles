{ pkgs, lib, ... }:

let
  # Function to convert directory names to kebab-case
  format-name = name:
    let
      formatted = lib.strings.replaceChars ["_"] ["-"] (lib.strings.toLowercase name);
    in
      lib.trace "Formatting directory name: ${name} -> ${formatted}" formatted;

  # Function to read all files in a directory and return them as an attribute set
  read-config-files = dir:
    let
      files = lib.filesystem.listFiles dir;
      traced-files = lib.trace "Reading files from directory: ${toString dir}" files;
    in
      builtins.listToAttrs (
        map
          (file: {
            name = baseNameOf file;
            value = builtins.readFile file;
          })
          traced-files
      );

  # Function to recursively map directories to their configurations
  generate-configs = dir:
    let
      directories = lib.filesystem.listDirectories dir;
      traced-dirs = lib.trace "Processing directory: ${toString dir}" directories;
    in
      builtins.listToAttrs (
        map (subdir: {
          name = format-name (baseNameOf subdir);
          value = if lib.filesystem.isDirectory subdir
                  then lib.trace "Entering subdirectory: ${toString subdir}" (generate-configs subdir)
                  else read-config-files dir;
        }) traced-dirs
      );

  # Load all configurations from the `config` directory
  configs = lib.trace "Starting to load configurations from ./config" (generate-configs ./);

in
{
  config = configs;
}
