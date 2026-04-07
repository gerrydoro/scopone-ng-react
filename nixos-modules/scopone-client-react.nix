{ config, lib, pkgs, ... }:

let
  cfg = config.services.scopone-client-react;

  # Build the package with the configured options
  clientPackage = pkgs.callPackage ./client-react.nix {
    inherit (cfg) serverAddress;
  };

  # The absolute path to the built static files inside the Nix store.
  # This is the value web servers (caddy, nginx, …) use as their root.
  # It automatically changes when the package is rebuilt, which causes
  # the web server service to be reloaded by NixOS.
  clientRoot = "${cfg.package}";
in
{
  meta.maintainers = [ lib.maintainers.gerrydoro ];

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
      description = "Host address to bind the client web server to.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 65026;
      description = "Port to listen on for the client web server.";
    };

    serverAddress = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        WebSocket address of the Scopone server.
        When null the client auto-detects the server from the browser domain.
      '';
    };

    # --- Web server choice ---
    enableWebServer = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Enable the built-in web server (Caddy or Nginx).
        Set to false to use the clientRoot in your own custom web server configuration.
      '';
    };

    useCaddy = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use Caddy to serve the static files.";
    };

    caddyVirtualHost = lib.mkOption {
      type = lib.types.str;
      default = "scopone-client";
      description = "The virtual host name for Caddy.";
    };

    useNginx = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use Nginx to serve the static files.";
    };

    # --- Exposed path for external use ---
    # Read-only: the Nix store path where the built static files live.
    # Useful for custom caddy/nginx configs defined outside this module.
    clientRoot = lib.mkOption {
      type = lib.types.str;
      default = clientRoot;
      readOnly = true;
      description = "The Nix store path containing the built static files.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.enableWebServer || cfg.useCaddy || cfg.useNginx;
        message = "services.scopone-client-react: enableWebServer is true, but both useCaddy and useNginx are false. Set enableWebServer to false or enable at least one web server.";
      }
    ];

    # ===== Caddy =====
    services.caddy = lib.mkIf (cfg.enableWebServer && cfg.useCaddy) {
      enable = true;
      # Using virtualHosts (not configFile) so this plays nicely with
      # other caddy configuration that may exist elsewhere.
      # Because `clientRoot` is embedded here, any rebuild of the client
      # package changes this derivation, which triggers a caddy reload.
      virtualHosts."${cfg.caddyVirtualHost}" = {
        extraConfig = ''
          bind ${cfg.host}
          root * ${clientRoot}
          encode gzip
          try_files {path} /index.html
          file_server
        '';
      };
    };

    # ===== Nginx =====
    services.nginx = lib.mkIf (cfg.enableWebServer && cfg.useNginx) {
      enable = true;

      virtualHosts."scopone-client-react" = {
        listen = [
          { addr = cfg.host; port = cfg.port; }
        ];

        root = clientRoot;

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
