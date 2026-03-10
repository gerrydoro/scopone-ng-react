{ lib, buildNpmPackage }:

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
    # Copy scopone-rx-service/src into client-react/src
    cp -r ${../scopone-rx-service}/src ./scopone-rx-service
    
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
              const scoponeRxServicePath = path.resolve(__dirname, "scopone-rx-service");
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
    
    # Update tsconfig.json to include scopone-rx-service
    cat > tsconfig.json << 'TSCONFIGEOF'
    {
      "compilerOptions": {
        "target": "es5",
        "lib": ["dom", "dom.iterable", "esnext"],
        "allowJs": true,
        "skipLibCheck": true,
        "esModuleInterop": true,
        "allowSyntheticDefaultImports": true,
        "strict": false,
        "downlevelIteration": true,
        "forceConsistentCasingInFileNames": true,
        "noFallthroughCasesInSwitch": true,
        "module": "esnext",
        "moduleResolution": "node",
        "resolveJsonModule": true,
        "isolatedModules": true,
        "noEmit": true,
        "jsx": "react-jsx",
        "baseUrl": "src",
        "paths": {
          "@scopone-rx-service/*": ["../scopone-rx-service/*"]
        }
      },
      "include": ["src", "scopone-rx-service"]
    }
    TSCONFIGEOF
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
