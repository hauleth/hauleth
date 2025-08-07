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
          ];

          buildPhase = ''
            zola --version
            zola build --output-dir $out
          '';

          dontInstall = true;
        };
      in
      {
        apps.publish = let
          program = pkgs.writeShellScript "publish" ''
            cp -r ${self.packages.${system}.blog} public
            '';
        in {
          type = "app";
          program = "${program}";
        };
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
