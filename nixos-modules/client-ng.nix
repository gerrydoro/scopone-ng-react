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

  sourceRoot = "source/client-ng";

  npmDepsHash = lib.fakeHash;
  npmDepsFetcherVersion = 2;
  npmFlags = [ "--legacy-peer-deps" ];
  makeCacheWritable = true;

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
    cp -r build/* $out/
  '';

  meta = with lib; {
    description = "Scopone card game - Angular 19 client";
    homepage = "https://github.com/gerardo/scopone-ng-react";
    license = licenses.mit;
    maintainers = [ maintainers.gerardo ];
  };
}
