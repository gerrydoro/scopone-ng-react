# Caddy Configuration for Dynamic Server Address

## Summary of Changes

The React client now supports **dynamic server address detection**. When you visit the client at a domain, it automatically connects to the corresponding server domain.

## How It Works

The client uses the following logic to determine the WebSocket server address:

1. **Environment variable override**: If `REACT_APP_SERVER_ADDRESS` is set, use it
2. **Domain-based detection** (production):
   - `https://scopone.gerryd.myaddr.io/` → `wss://server-scopone.gerryd.myaddr.io/osteria`
   - `https://scopone.gerryd.it/` → `wss://server-scopone.gerryd.it/osteria`
   - Any other domain → `wss://<same-domain>/osteria`
3. **Development fallback**: `ws://localhost:65025/osteria`

## Required Caddy Configuration

Your current Caddy setup is **already correct** for this to work! The key requirements are:

### 1. Client Domain
The React client must be served at:
- `scopone.gerryd.myaddr.io` (public)
- `scopone` (private/internal)

### 2. Server Domain
The Go WebSocket server must be accessible at:
- `server-scopone.gerryd.myaddr.io` (via reverse proxy)
- `server-scopone` (private/internal on port 65025)

### Example Configuration

```nix
services.caddy.virtualHosts =
  # WebSocket server (internal access on port 65025)
  (config.caddyLib.mkPrivateReverseProxy "server-scopone" 65025)
  
  # Public reverse proxy for server-scopone.gerryd.it
  // (config.caddyLib.mkPublicReverseProxyToAnubisInstance "server-scopone.gerryd.it" "server-scopone")
  
  # React client - public
  // (config.caddyLib.mkWebservers
    inputs.scopone-ng-react.packages.${pkgs.system}.scopone-client-react
    [ "scopone.gerryd.myaddr.io" ]
  )
  
  # React client - private
  // (config.caddyLib.mkPrivateWebserver
    inputs.scopone-ng-react.packages.${pkgs.system}.scopone-client-react
    "scopone"
  );
```

## NixOS Module Options

The `scopone-client-react` NixOS module now supports an optional `serverAddress` parameter:

```nix
# Option 1: Use dynamic detection (DEFAULT - recommended)
services.scopone-client-react = {
  enable = true;
  # serverAddress = null;  # null = auto-detect from browser domain
};

# Option 2: Explicitly set server address
services.scopone-client-react = {
  enable = true;
  serverAddress = "wss://server-scopone.gerryd.myaddr.io/osteria";
};
```

## Testing

After applying the configuration:

1. Rebuild your NixOS system:
   ```bash
   sudo nixos-rebuild switch --flake .#ASUS
   ```

2. Visit `https://scopone.gerryd.myaddr.io/` in your browser

3. Open browser DevTools → Network tab → WS (WebSockets)

4. You should see a WebSocket connection to:
   `wss://server-scopone.gerryd.myaddr.io/osteria`

## Troubleshooting

### WebSocket connection fails

1. Check that `server-scopone.gerryd.myaddr.io` resolves correctly
2. Verify the Caddy reverse proxy is running:
   ```bash
   sudo systemctl status caddy
   ```
3. Check Caddy logs:
   ```bash
   sudo journalctl -u caddy -f
   ```

### Still connecting to localhost

1. Clear your browser cache
2. Do a hard refresh (Ctrl+Shift+R or Cmd+Shift+R)
3. Verify the built client has the dynamic detection code:
   ```bash
   grep -o "getServerAddress" /nix/store/*-scopone-client-react*/index.html
   ```

## Files Modified

- `client-react/src/helpers/server-address.ts` - New helper function
- `client-react/src/components/game/game.tsx` - Uses dynamic server address
- `nixos-modules/client-react.nix` - Optional serverAddress parameter
- `nixos-modules/scopone-client-react.nix` - Updated option documentation
