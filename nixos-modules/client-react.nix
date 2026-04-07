{ lib
, buildNpmPackage
, nodejs
, serverAddress ? null
}:

let
  scoponeRxServiceSrc = lib.cleanSourceWith {
    src = ../scopone-rx-service;
    filter = path: type:
      let
        baseName = baseNameOf (toString path);
      in
      !(lib.hasPrefix "." baseName);
  };
in
buildNpmPackage {
  pname = "scopone-client-react";
  version = "0.2.0";

  src = lib.cleanSourceWith {
    src = ../client-react;
    filter = path: type:
      let
        baseName = baseNameOf (toString path);
      in
      !(lib.hasPrefix "." baseName && baseName != ".env");
  };

  nativeBuildInputs = [ nodejs ];

  # Copy scopone-rx-service into the build tree and configure environment
  postPatch = ''
    # Place scopone-rx-service where the craco config expects it
    mkdir -p ../scopone-rx-service
    cp -r ${scoponeRxServiceSrc}/* ../scopone-rx-service/

    # Write .env.production with the configured server address
    cat > .env.production <<EOF
    ${lib.optionalString (serverAddress != null) "REACT_APP_SERVER_ADDRESS=${serverAddress}"}
    EOF

    # Write a self-contained craco config that resolves the external library
    cat > craco.config.js <<'CRACO'
    const path = require("path");

    const scoponeRxServiceLib = path.resolve(__dirname, "../scopone-rx-service/src");

    module.exports = {
      webpack: {
        configure: (config) => {
          // Remove ModuleScopePlugin so imports outside src/ are allowed
          const idx = config.resolve.plugins.findIndex(
            ({ constructor }) => constructor && constructor.name === "ModuleScopePlugin"
          );
          if (idx !== -1) {
            config.resolve.plugins.splice(idx, 1);
          }

          // Add scopone-rx-service to the TypeScript/TSX loader include
          const oneOfRule = config.module.rules.find((r) => r.oneOf);
          if (oneOfRule) {
            const tsRule = oneOfRule.oneOf.find(
              (r) => r.test && r.test.toString().includes("tsx")
            );
            if (tsRule) {
              tsRule.include = Array.isArray(tsRule.include)
                ? [...tsRule.include, scoponeRxServiceLib]
                : [tsRule.include, scoponeRxServiceLib];
            }
          }

          return config;
        },
      },
      typescript: {
        enableTypeChecking: false,
      },
    };
    CRACO
  '';

  npmDepsHash = "sha256-qfc17jfpnxnmMlAcvuB++mf5SRbblIqpLV8aREw6wus=";
  npmDepsFetcherVersion = 2;
  makeCacheWritable = true;
  npmFlags = [ "--legacy-peer-deps" ];
  enableParallelBuilding = true;

  # React 17 / webpack compatibility
  env.NODE_OPTIONS = "--openssl-legacy-provider";
  env.npm_config_offline = "true";
  env.npm_config_prefer_offline = "true";
  env.npm_config_fund = "false";
  env.npm_config_audit = "false";
  env.npm_config_progress = "false";
  env.CI = "true";

  buildPhase = ''
    runHook preBuild
    npm run build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r build/* $out/
    runHook postInstall
  '';

  # Expose the output path so NixOS modules (nginx, caddy, …) can reference it
  passthru.outPath = "/";

  meta = with lib; {
    description = "Scopone card game – React client";
    homepage = "https://github.com/gerrydoro/scopone-ng-react";
    license = licenses.mit;
    maintainers = [ maintainers.gerrydoro ];
  };
}
