{ pkgs ? import <nixpkgs> {}, ... }:

with pkgs;

stdenv.mkDerivation {
  name = "hauleth-blog";
  src = ./.;

  nativeBuildInputs = [ git ];
  buildInputs = [ zola ];

  buildPhase = ''
    git submodule update --init --recursive --depth=1
    zola build -o $out
    '';

  dontInstall = true;

  passthru = {
    inherit zola;
  };
}
