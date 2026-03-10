{ lib, buildNpmPackage }:

buildNpmPackage rec {
  pname = "scopone-client-ng";
  version = "0.0.4";

  src = ../client-ng;

  npmDepsHash = "sha256-R6HROzrIxL4xPa6ON4wNYQK59CzK1ROEyAjxhw2U3CY=";

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
