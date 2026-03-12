{ lib
, buildNpmPackage
, serverAddress ? "ws://localhost:65025/osteria"
}:

buildNpmPackage rec {
  pname = "scopone-client-ng";
  version = "0.0.6";

  src = lib.cleanSourceWith {
    src = ../client-ng;
    filter = path: type:
      let
        baseName = baseNameOf (toString path);
      in
        !(lib.hasPrefix "." baseName && baseName != ".env");
  };

  npmDepsHash = "sha256-0akXGp8wBPk3YAQRgZXM9KVqmF3tErG1BSG5DkRaG1M=";
  npmFlags = [ "--legacy-peer-deps" ];

  # Copy scopone-rx-service and create environment.prod.ts
  postPatch = ''
    # Copy scopone-rx-service to parent directory
    cp -r ${../scopone-rx-service} ../scopone-rx-service

    # Create environment.prod.ts with configurable server address
    cat > src/environments/environment.prod.ts << ENVFILE
    export const environment = {
      production: true,
      serverAddress: '${serverAddress}',
    };
    ENVFILE

    # Update tsconfig.json to add paths for scopone-rx-service
    cat > tsconfig.json << 'TSCONFIG'
    {
      "compileOnSave": false,
      "compilerOptions": {
        "outDir": "./dist/out-tsc",
        "strict": false,
        "noImplicitOverride": false,
        "noPropertyAccessFromIndexSignature": false,
        "noImplicitReturns": false,
        "noFallthroughCasesInSwitch": false,
        "skipLibCheck": true,
        "esModuleInterop": true,
        "sourceMap": true,
        "declaration": false,
        "experimentalDecorators": true,
        "moduleResolution": "bundler",
        "importHelpers": true,
        "target": "ES2022",
        "module": "ES2022",
        "useDefineForClassFields": false,
        "lib": ["ES2022", "dom"],
        "strictPropertyInitialization": false,
        "baseUrl": "./",
        "paths": {
          "rxjs": ["node_modules/rxjs"],
          "rxjs/*": ["node_modules/rxjs/*"]
        }
      },
      "angularCompilerOptions": {
        "enableI18nLegacyMessageIdFormat": false,
        "strictInjectionParameters": false,
        "strictInputAccessModifiers": false,
        "strictTemplates": false
      }
    }
    TSCONFIG

    # Disable Angular analytics
    mkdir -p .angular
    echo '{"analytics":false}' > .angular/config.json
  '';

  buildPhase = ''
    export NG_CLI_ANALYTICS=false
    npm run build -- --configuration=production
  '';

  installPhase = ''
    mkdir -p $out
    cp -r dist/client-ng/browser/* $out/
  '';

  passthru = {
    # Provide the package path for nginx root
    outPath = "/";
  };

  meta = with lib; {
    description = "Scopone card game - Angular 19 client";
    homepage = "https://github.com/gerardo/scopone-ng-react";
    license = licenses.mit;
    maintainers = [ maintainers.gerardo ];
  };
}
