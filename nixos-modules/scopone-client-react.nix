{ config, lib, pkgs, ... }:

let
  cfg = config.services.scopone-client-react;

  # Create the package with the configured server address
  clientPackage = pkgs.callPackage ./client-react.nix {
    inherit (cfg) serverAddress;
  };
in
{
  meta.maintainers = [ lib.maintainers.gerardo ];

  options.services.scopone-client-react = {
    enable = lib.mkEnableOption "Scopone React client";

    package = lib.mkOption {
      type = lib.types.package;
      default = clientPackage;
      description = "The Scopone React client package to use.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "The host address to bind the client web server to.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 65026;
      description = "The port to listen on for the client web server.";
    };

    serverAddress = lib.mkOption {
      type = lib.types.str;
      default = "ws://localhost:65025/osteria";
      description = "The WebSocket address of the Scopone server.";
    };

    useNginx = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to use nginx to serve the static files.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx = lib.mkIf cfg.useNginx {
      enable = true;

      virtualHosts."${cfg.host}" = {
        listen = [
          { addr = cfg.host; port = cfg.port; }
        ];

        root = cfg.package;

        locations."/" = {
          tryFiles = "$uri $uri/ /index.html";
          extraConfig = ''
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            add_header Pragma "no-cache";
            add_header Expires "0";
          '';
        };
      };
    };

    networking.firewall.allowedTCPPorts = lib.optional cfg.enable cfg.port;

    environment.systemPackages = lib.optional cfg.enable cfg.package;
  };
}
