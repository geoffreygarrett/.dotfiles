{ lib, writeShellScriptBin }:

target: wrapper:
writeShellScriptBin (baseNameOf wrapper) ''
  exec "${target}" "$@"
''
