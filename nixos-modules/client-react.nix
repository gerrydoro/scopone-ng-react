{ lib, buildNpmPackage }:

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
buildNpmPackage rec {
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

  postPatch = ''
    # Copy scopone-rx-service to parent directory (project root level)
    mkdir -p ..
    cp -r ${scoponeRxServiceSrc}/src ../scopone-rx-service/src
    
    cat > .env.production << 'ENVFILE'
    REACT_APP_SERVER_ADDRESS=ws://localhost:8080/osteria
    ENVFILE
    
    # Update craco config
    cat > craco.config.js << 'CRACOEOF'
    const path = require("path");
    
    module.exports = {
      webpack: {
        configure: (config) => {
          // Find and remove ModuleScopePlugin
          const scopePluginIndex = config.resolve.plugins.findIndex(
            ({ constructor }) => constructor && constructor.name === 'ModuleScopePlugin'
          );
          if (scopePluginIndex !== -1) {
            config.resolve.plugins.splice(scopePluginIndex, 1);
          }
          
          // Add scopone-rx-service to TypeScript loader
          const oneOfRule = config.module.rules.find((rule) => rule.oneOf);
          if (oneOfRule) {
            const tsRule = oneOfRule.oneOf.find(
              (rule) => rule.test && rule.test.toString().includes("tsx")
            );
            if (tsRule) {
              const scoponeRxServicePath = path.resolve(__dirname, "../scopone-rx-service/src");
              tsRule.include = Array.isArray(tsRule.include)
                ? [...tsRule.include, scoponeRxServicePath]
                : [tsRule.include, scoponeRxServicePath];
            }
          }
          
          return config;
        },
      },
    };
    CRACOEOF
  '';

  npmDepsHash = "sha256-JTzTOnKIstTkNVKN26YsqXUca2QGu6W7e5luSHFvy2Y=";

  # Use legacy OpenSSL provider
  env.NODE_OPTIONS = "--openssl-legacy-provider";
  env.npm_config_offline = "true";
  env.npm_config_prefer_offline = "true";
  env.npm_config_fund = "false";
  env.npm_config_audit = "false";
  env.npm_config_progress = "false";
  env.CI = "true";

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
