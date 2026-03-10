{ lib, buildNpmPackage }:

buildNpmPackage rec {
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

  sourceRoot = "source";

  npmDepsHash = "sha256-JTzTOnKIstTkNVKN26YsqXUca2QGu6W7e5luSHFvy2Y=";

  postPatch = ''
    cd client-react
    cat > .env.production << 'ENVFILE'
    REACT_APP_SERVER_ADDRESS=ws://localhost:8080/osteria
    ENVFILE
  '';

  # Use legacy OpenSSL provider for compatibility with older webpack
  env.NODE_OPTIONS = "--openssl-legacy-provider";

  # Prevent network access and interactive prompts
  env.npm_config_offline = "true";
  env.npm_config_prefer_offline = "true";
  env.npm_config_fund = "false";
  env.npm_config_audit = "false";
  env.npm_config_progress = "false";
  env.CI = "true";

  buildPhase = ''
    cd client-react
    npm run build
  '';

  installPhase = ''
    mkdir -p $out
    cp -r client-react/build/* $out/
  '';

  meta = with lib; {
    description = "Scopone card game - React client";
    homepage = "https://github.com/gerardo/scopone-ng-react";
    license = licenses.mit;
    maintainers = [ maintainers.gerardo ];
  };
}
