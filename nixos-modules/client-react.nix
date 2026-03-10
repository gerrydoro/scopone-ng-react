{ lib, stdenv, nodejs }:

stdenv.mkDerivation rec {
  pname = "scopone-client-react";
  version = "0.1.6";

  src = lib.cleanSourceWith {
    src = ../client-react;
    filter = path: type:
      let
        baseName = baseNameOf (toString path);
      in
        !(lib.hasPrefix "." baseName && baseName != ".env");
  };

  buildInputs = [ nodejs ];

  postPatch = ''
    echo "REACT_APP_SERVER_ADDRESS=ws://localhost:8080/osteria" > .env.production
    # Copy scopone-rx-service/src into place
    mkdir -p ../scopone-rx-service
    cp -r ${../scopone-rx-service}/src ../scopone-rx-service/
  '';

  buildPhase = ''
    npm install
    NODE_OPTIONS="--openssl-legacy-provider" npm run build
  '';

  installPhase = ''
    mkdir -p $out
    cp -r build/* $out/
  '';

  meta = with lib; {
    description = "Scopone card game - React client";
    homepage = "https://github.com/gerardo/scopone-ng-react";
    license = licenses.mit;
    maintainers = [ maintainers.gerardo ];
  };
}
