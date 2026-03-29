# Server Address Configuration

## How It Works

The React client automatically derives the WebSocket server address from the browser's current location using a simple rule:

**Add `server-` prefix to the current hostname**

### Examples

| Client URL | Server WebSocket URL |
|------------|---------------------|
| `https://scopone.gerryd.myaddr.io/` | `wss://server-scopone.gerryd.myaddr.io/osteria` |
| `https://bestscopone.it/` | `wss://server-bestscopone.it/osteria` |
| `http://localhost:3000/` | `ws://server-localhost:3000/osteria` |
| `https://myapp.example.com:8443/` | `wss://server-myapp.example.com:8443/osteria` |

## Caddy Configuration Required

For this to work, you need to ensure:

1. **Client** is served at the domain (e.g., `scopone.gerryd.myaddr.io`)
2. **Server** is accessible at `server-` prefixed domain (e.g., `server-scopone.gerryd.myaddr.io`)

### Example NixOS Configuration

```nix
{
  config,
  pkgs,
  inputs,
  ...
}:

{
  # Scopone Server - WebSocket game server on port 65025
  services.scopone-server = {
    enable = true;
    package = inputs.scopone-ng-react.packages.${pkgs.system}.scopone-server;
    port = 65025;
  };

  # Caddy virtual hosts
  services.caddy.virtualHosts =
    # Server: accessible at server-scopone.* (reverse proxy to port 65025)
    (config.caddyLib.mkPrivateReverseProxy "server-scopone" 65025)
    
    # Client: React app served at scopone.*
    // (config.caddyLib.mkWebservers
      inputs.scopone-ng-react.packages.${pkgs.system}.scopone-client-react
      [ "scopone.gerryd.myaddr.io" ]
    );
}
```

## Override (Optional)

To use a custom server address, set the environment variable:

```nix
# In your NixOS module or package call
pkgs.callPackage "${inputs.scopone-ng-react}/nixos-modules/client-react.nix" {
  serverAddress = "wss://custom-server-address/osteria";
}
```

## Testing

1. Visit your client domain (e.g., `https://scopone.gerryd.myaddr.io/`)
2. Open browser DevTools → Network → WS
3. Verify WebSocket connects to `wss://server-scopone.gerryd.myaddr.io/osteria`
