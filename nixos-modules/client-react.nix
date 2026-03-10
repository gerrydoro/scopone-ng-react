{ lib, stdenv, nodejs, git }:

stdenv.mkDerivation rec {
  pname = "scopone-client-react";
  version = "0.1.6";

  src = lib.cleanSourceWith {
    src = ../client-react;
    filter = path: type:
      let
        relPath = lib.removePrefix (toString ../client-react + "/") (toString path);
        baseName = baseNameOf (toString path);
      in
        !(lib.hasPrefix "." baseName && baseName != ".env") &&
        !lib.hasPrefix "node_modules/" relPath &&
        !lib.hasPrefix "build/" relPath;
  };

  buildInputs = [ nodejs git ];

  # Copy scopone-rx-service/src before npm install
  postPatch = ''
    # Create scopone-rx-service directory and copy src
    mkdir -p ../scopone-rx-service
    cp -r ${../scopone-rx-service}/src ../scopone-rx-service/src
    
    # Create .env.production
    cat > .env.production << 'ENVFILE'
    REACT_APP_SERVER_ADDRESS=ws://localhost:8080/osteria
    ENVFILE
  '';

  # Configure npm to not hang
  preBuild = ''
    export npm_config_fund=false
    export npm_config_audit=false
    export npm_config_progress=false
    export CI=true
  '';

  buildPhase = ''
    npm ci --legacy-peer-deps
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
