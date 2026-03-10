{ lib, stdenv, nodejs, rsync }:

stdenv.mkDerivation rec {
  pname = "scopone-client-react";
  version = "0.1.6";

  src = lib.cleanSourceWith {
    src = ../.;
    filter = path: type:
      let
        relPath = lib.removePrefix (toString ../. + "/") (toString path);
      in
        lib.hasPrefix "client-react/" relPath || 
        lib.hasPrefix "scopone-rx-service/src/" relPath;
  };

  buildInputs = [ nodejs rsync ];

  sourceRoot = "source";

  postPatch = ''
    echo "REACT_APP_SERVER_ADDRESS=ws://localhost:8080/osteria" > client-react/.env.production
  '';

  buildPhase = ''
    cd client-react
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
