{ pkgs ? import <nixpkgs> {}, ... }:

let
  blog = import ./. {};
in
  pkgs.mkShell {
    buildInputs = [
      blog.zola
      pkgs.pandoc
      pkgs.texlive.combined.scheme-small
      pkgs.vale
      pkgs.mdl
    ];
  }
