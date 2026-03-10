{ lib
, buildNpmPackage
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

  npmDepsHash = "sha256-8p50KjBsod41BpmQqDmAE/Gvz3Rrf8KRUmyHBA61x6A=";
  npmDepsFetcherVersion = 2;
  npmFlags = [ "--legacy-peer-deps" ];
  makeCacheWritable = true;

  # Copy scopone-rx-service and create environment.prod.ts
  postPatch = ''
    # Copy scopone-rx-service
    cp -r ${../scopone-rx-service} ../scopone-rx-service
    
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
