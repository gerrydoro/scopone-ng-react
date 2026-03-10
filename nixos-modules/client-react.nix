{ lib, buildNpmPackage }:

buildNpmPackage rec {
  pname = "scopone-client-react";
  version = "0.1.6";

  src = lib.cleanSourceWith {
    src = ../client-react;
    filter = path: type: builtins.pathExists path;
  };

  npmDepsHash = "sha256-JTzTOnKIstTkNVKN26YsqXUca2QGu6W7e5luSHFvy2Y=";

  # Copy scopone-rx-service into the build directory
  postPatch = ''
    cp -r ${../scopone-rx-service} ../scopone-rx-service
    cat > .env.production << 'ENVFILE'
    REACT_APP_SERVER_ADDRESS=ws://localhost:8080/osteria
    ENVFILE
  '';

  # Use legacy OpenSSL provider for compatibility with older webpack
  env.NODE_OPTIONS = "--openssl-legacy-provider";

  buildPhase = ''
    npm run build
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
