{ lib
, buildNpmPackage
}:

buildNpmPackage rec {
  pname = "scopone-client-ng";
  version = "0.0.5";

  src = lib.cleanSourceWith {
    src = ../.;
    filter = path: type:
      let
        relPath = lib.removePrefix (toString ../. + "/") (toString path);
      in
        lib.hasPrefix "client-ng/" relPath || 
        lib.hasPrefix "scopone-rx-service/" relPath;
  };

  sourceRoot = "source";

  npmDepsHash = lib.fakeHash;
  npmDepsFetcherVersion = 2;
  npmFlags = [ "--legacy-peer-deps" ];
  makeCacheWritable = true;

  # Move client-ng to root and create environment.prod.ts
  postPatch = ''
    # Move client-ng contents to root
    mv client-ng/* .
    mv client-ng/.* . 2>/dev/null || true
    rm -rf client-ng
    
    # Create environment.prod.ts
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
    cp -r build/* $out/
  '';

  meta = with lib; {
    description = "Scopone card game - Angular 19 client";
    homepage = "https://github.com/gerardo/scopone-ng-react";
    license = licenses.mit;
    maintainers = [ maintainers.gerardo ];
  };
}
