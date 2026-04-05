{ config, lib, pkgs, ... }:

let
  cfg = config.services.scopone-client-react;

  # Build the package with the configured options
  clientPackage = pkgs.callPackage ./client-react.nix {
    inherit (cfg) serverAddress;
  };

  # The absolute path to the built static files inside the Nix store.
  # This is the value web servers (caddy, nginx, …) use as their root.
  # It automatically changes when the package is rebuilt, triggering a
  # service reload.
  clientRoot = "${cfg.package}";

  # ---------- Caddyfile fragment ----------
  caddyfile = pkgs.writeText "scopone-client-react.Caddyfile" ''
    ${cfg.host}:${toString cfg.port} {
      root * ${clientRoot}
      encode gzip
      try_files {path} /index.html
      file_server
    }
  '';
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
    useCaddy = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use Caddy to serve the static files.";
    };

    useNginx = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use Nginx to serve the static files.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.useCaddy || cfg.useNginx;
        message = "services.scopone-client-react: at least one of useCaddy or useNginx must be true.";
      }
    ];

    # ===== Caddy =====
    services.caddy = lib.mkIf cfg.useCaddy {
      enable = true;
      enableReload = true;
      # The Caddyfile references `clientRoot` which changes on every rebuild.
      # NixOS will automatically reload Caddy when the path changes.
      configFile = caddyfile;
    };

    # ===== Nginx =====
    services.nginx = lib.mkIf cfg.useNginx {
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
