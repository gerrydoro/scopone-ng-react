{ lib, buildNpmPackage, nodejs_20 }:

buildNpmPackage rec {
  pname = "scopone-client-ng";
  version = "0.0.4";

  src = ../client-ng;

  nodejs = nodejs_20;

  npmDepsHash = "sha256-R6HROzrIxL4xPa6ON4wNYQK59CzK1ROEyAjxhw2U3CY=";

  # Create environment.prod.ts at build time
  postPatch = ''
    cat > src/environments/environment.prod.ts << 'ENVFILE'
    export const environment = {
      production: true,
      serverAddress: 'ws://localhost:8080/osteria',
    };
    ENVFILE
  '';

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
