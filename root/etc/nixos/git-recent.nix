with import <nixpkgs> {};
with pkgs;

{ stdenv, lib }:

let
  script = builtins.readFile ./git-recent;
in
pkgs.writeShellScriptBin "git-recent" ''
#! ${stdenv.shell}
${script}
''
