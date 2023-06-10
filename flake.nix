{
  description = "Flake utils demo";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
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

          passthru = {
            inherit (pkgs) zola;
          };
        };
      in rec {
        packages = {
          inherit blog;
        };
        defaultPackage = blog;
        /* apps.hello = flake-utils.lib.mkApp { drv = packages.hello; }; */
        /* defaultApp = apps.hello; */

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [
            blog.zola
            pkgs.vale
            pkgs.mdl
          ];
        };
      }
    );
}
