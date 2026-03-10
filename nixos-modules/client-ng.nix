{ lib
, buildNpmPackage
, nodejs
, python3
}:

buildNpmPackage rec {
  pname = "scopone-client-ng";
  version = "0.0.5";

  src = lib.cleanSourceWith {
    src = ../client-ng;
    filter = path: type:
      let
        baseName = baseNameOf (toString path);
      in
        !(lib.hasPrefix "." baseName && baseName != ".env");
  };

  npmDepsHash = lib.fakeHash;
  npmDepsFetcherVersion = 2;

  nativeBuildInputs = [ python3 ];

  # Create environment.prod.ts at build time
  postPatch = ''
    cat > src/environments/environment.prod.ts << 'ENVFILE'
    export const environment = {
      production: true,
      serverAddress: 'ws://localhost:8080/osteria',
    };
    ENVFILE
  '';

  # Configure for offline build
  env.npm_config_offline = "true";
  env.npm_config_prefer_offline = "true";
  env.npm_config_fund = "false";
  env.npm_config_audit = "false";
  env.npm_config_progress = "false";
  env.CI = "true";

  buildPhase = ''
    npm run build -- --configuration=production
  '';

  installPhase = ''
    mkdir -p $out
    cp -r dist/client-ng/browser/* $out/
  '';

  meta = with lib; {
    description = "Scopone card game - Angular 19 client";
    homepage = "https://github.com/gerardo/scopone-ng-react";
    license = licenses.mit;
    maintainers = [ maintainers.gerardo ];
  };
}
