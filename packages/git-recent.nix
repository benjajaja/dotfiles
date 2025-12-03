{ stdenv, lib, pkgs, ... }:

let
  script = builtins.readFile ./git-recent;
in
pkgs.writeShellScriptBin "git-recent" ''
#! ${stdenv.shell}
${script}
''
