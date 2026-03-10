{ lib, buildNpmPackage, runCommand }:

buildNpmPackage rec {
  pname = "scopone-client-ng";
  version = "0.0.4";

  src = ../client-ng;

  npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  buildPhase = ''
    npm run build -- --configuration=production
  '';

  installPhase = ''
    mkdir -p $out
    cp -r dist/client/* $out/
  '';

  meta = with lib; {
    description = "Scopone card game - Angular client";
    homepage = "https://github.com/gerardo/scopone-ng-react";
    license = licenses.mit;
    maintainers = [ maintainers.gerardo ];
  };
}
