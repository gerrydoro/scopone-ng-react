{
  lib,
  buildNpmPackage,
  nodejs,
  serverAddress ? null, # null = use dynamic detection from browser domain
}:

let
  scoponeRxServiceSrc = lib.cleanSourceWith {
    src = ../scopone-rx-service;
    filter =
      path: type:
      let
        baseName = baseNameOf (toString path);
      in
      !(lib.hasPrefix "." baseName);
  };
in
buildNpmPackage rec {
  pname = "scopone-client-react";
  version = "0.2.2";

  src = lib.cleanSourceWith {
    src = ../client-react;
    filter =
      path: type:
      let
        baseName = baseNameOf (toString path);
      in
      !(lib.hasPrefix "." baseName && baseName != ".env");
  };

  postPatch = ''
    # Copy scopone-rx-service to parent directory with correct structure
    mkdir -p ../scopone-rx-service
    cp -r ${scoponeRxServiceSrc}/* ../scopone-rx-service/

    # Create .env.production with configurable server address
    # If serverAddress is null/empty, leave it empty to use dynamic detection
    ${lib.optionalString (serverAddress != null) ''
      cat > .env.production << ENVFILE
      REACT_APP_SERVER_ADDRESS=${serverAddress}
      ENVFILE
    ''}
    ${lib.optionalString (serverAddress == null) ''
      cat > .env.production << ENVFILE
      # Empty - will use dynamic server address detection from browser domain
      ENVFILE
    ''}

    # Update craco config to use the correct path and configure TypeScript
    cat > craco.config.js << 'CRACOEOF'
    const path = require("path");

    const findWebpackPlugin = (webpackConfig, pluginName) =>
        webpackConfig.resolve.plugins.find(
            ({ constructor }) => constructor && constructor.name === pluginName
        );

    const enableTypescriptImportsFromExternalPaths = (
        webpackConfig,
        newIncludePaths
    ) => {
        const oneOfRule = webpackConfig.module.rules.find((rule) => rule.oneOf);
        if (oneOfRule) {
            const tsxRule = oneOfRule.oneOf.find(
                (rule) => rule.test && rule.test.toString().includes("tsx")
            );

            if (tsxRule) {
                tsxRule.include = Array.isArray(tsxRule.include)
                    ? [...tsxRule.include, ...newIncludePaths]
                    : [tsxRule.include, ...newIncludePaths];
            }
        }
    };

    const addPathsToModuleScopePlugin = (webpackConfig, paths) => {
        const moduleScopePlugin = findWebpackPlugin(
            webpackConfig,
            "ModuleScopePlugin"
        );
        if (!moduleScopePlugin) {
            throw new Error(
                `Expected to find plugin "ModuleScopePlugin", but didn't.`
            );
        }
        moduleScopePlugin.appSrcs = [...moduleScopePlugin.appSrcs, ...paths];
    };

    const enableImportsFromExternalPaths = (webpackConfig, paths) => {
        enableTypescriptImportsFromExternalPaths(webpackConfig, paths);
        addPathsToModuleScopePlugin(webpackConfig, paths);
    };

    // Paths to the code you want to use
    const scopone_rx_service_lib = path.resolve(__dirname, "../scopone-rx-service/src");

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
                        tsRule.include = Array.isArray(tsRule.include)
                            ? [...tsRule.include, scopone_rx_service_lib]
                            : [tsRule.include, scopone_rx_service_lib];
                    }
                }

                return config;
            },
        },
        typescript: {
            enableTypeChecking: false, // Disable type checking for external packages
        },
    };
    CRACOEOF
  '';

  npmDepsHash = "sha256-gGt7Luhp2EK5MTYVSQpCLGAzaoq42sT6X0xHMB1Pb6o=";
  npmDepsFetcherVersion = 2;
  makeCacheWritable = true;
  npmFlags = [ "--legacy-peer-deps" ];
  enableParallelBuilding = true;

  # Use legacy OpenSSL provider for React 17 compatibility
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
