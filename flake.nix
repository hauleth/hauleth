{
  description = "Flake utils demo";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        blog = pkgs.stdenvNoCC.mkDerivation {
          name = "hauleth-blog";
          src = ./.;

          nativeBuildInputs = [
            pkgs.zola
            pkgs.gitMinimal
          ];

          buildPhase = ''
            git submodule update --init --recursive --depth=1
            zola build -o $out
          '';

          dontInstall = true;
        };
      in
      {
        packages = {
          inherit blog;
        };
        defaultPackage = blog;

        devShells.default = pkgs.mkShell {
          inputsFrom = [ blog ];

          packages = [
            # pkgs.netlify-cli
            pkgs.vale
            pkgs.mdl
          ];
        };
      }
    );
}
