{ pkgs ? import <nixpkgs> {}, ... }:

let
  blog = import ./. {};
in
  pkgs.mkShell {
    buildInputs = [
      blog.zola
      pkgs.vale
      pkgs.mdl
    ];
  }
