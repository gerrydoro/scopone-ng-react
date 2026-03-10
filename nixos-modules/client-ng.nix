{ lib
, stdenv
, nodejs
, python3
}:

stdenv.mkDerivation rec {
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

  nativeBuildInputs = [ nodejs python3 ];

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
    export HOME=$(mktemp -d)
    export NODE_OPTIONS="--openssl-legacy-provider"
    npm install --legacy-peer-deps
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
