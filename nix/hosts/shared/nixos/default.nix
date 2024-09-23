{ ... }:
{
  imports = map (n: "${./${n}}") (builtins.attrNames (builtins.readDir "./"));
}
