{ config, lib, pkgs, ... }:

let
  cfg = config.services.scopone-server;
  
  appEnv = pkgs.writeText "app.env" ''
    VERSION="2.0.0"
  '';
in
{
  meta.maintainers = [ lib.maintainers.gerardo ];

  options.services.scopone-server = {
    enable = lib.mkEnableOption "Scopone card game server";

    package = lib.mkOption {
      type = lib.types.package;
      description = "The Scopone server package to use.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "The host address to bind the server to.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "The port to listen on.";
    };

    mongoConnection = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        MongoDB connection string. If null, the server runs in in-memory mode.
        Example: "mongodb://user:password@host:port/scopone?retryWrites=true&w=majority"
      '';
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to a file containing environment variables.
        Useful for storing sensitive data like MongoDB credentials.
      '';
    };

    extraEnvironment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Additional environment variables to set.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.scopone-server = {
      description = "Scopone Card Game Server";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        GIN_MODE = "release";
      } // cfg.extraEnvironment // lib.optionalAttrs (cfg.mongoConnection != null) {
        MONGO_CONNECTION = cfg.mongoConnection;
      };

      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/scopone-in-memory-only";
        WorkingDirectory = "${appEnv}/..";
        Restart = "on-failure";
        RestartSec = "5s";
        
        # Security hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        
        # Network restrictions
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
        
        # Resource limits
        LimitNOFILE = 65536;
      };

      preStart = ''
        echo "Starting Scopone server..."
        cp ${appEnv} ./app.env
      '';
    };

    networking.firewall.allowedTCPPorts = lib.optional cfg.enable cfg.port;

    environment.systemPackages = lib.optional cfg.enable cfg.package;
  };
}
