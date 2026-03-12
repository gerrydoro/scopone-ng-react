# Scopone Nix Modules - Progress Tracking

## Overview
This document tracks the progress of creating and completing Nix modules for the Scopone project, a digital version of the Italian card game.

## Project Structure

The Scopone solution consists of the following sub-projects:

1. **server** - Go WebSocket server (with MongoDB support)
2. **client-ng** - Angular 19 client
3. **client-react** - React 17 client
4. **scopone-rx-service** - Shared TypeScript service library (used by both clients)
5. **serverless-cd** - CI/CD scripts (not packaged as Nix module)

## Nix Modules Status

### Packages (flake.nix)

| Package | File | Status | Notes |
|---------|------|--------|-------|
| scopone-server | nixos-modules/default.nix | ✅ Complete | Go module using go_1_24 |
| scopone-client-ng | nixos-modules/client-ng.nix | ✅ Complete | Angular build with rxjs paths configured |
| scopone-client-react | nixos-modules/client-react.nix | ✅ Complete | React build with craco configuration |

### NixOS Modules

| Module | File | Status | Notes |
|--------|------|--------|-------|
| scopone-server | nixos-modules/scopone-server.nix | ✅ Complete | Systemd service with security hardening |
| scopone-client-ng | nixos-modules/scopone-client-ng.nix | ✅ Complete | nginx-based static file serving |
| scopone-client-react | nixos-modules/scopone-client-react.nix | ✅ Complete | nginx-based static file serving |

## Tasks Completed

- [x] Initial review of existing Nix modules
- [x] Update main flake.nix exports (added client-react)
- [x] Fix scopone-client-react.nix module (use package option, add useNginx)
- [x] Fix client-react.nix package (proper scopone-rx-service integration)
- [x] Fix client-ng.nix package (rxjs paths, version update)
- [x] Fix scopone-server.nix module (user/group, security hardening)
- [x] Fix default.nix server package (go_1_24)
- [x] Test building all packages with `nix build`
- [x] Update /etc/nixos/apps/scopone.nix with Caddy configuration
- [x] Update /etc/nixos/flake.nix to include all modules and packages
- [x] Rebuild system with `nixos-rebuild switch`
- [x] Verify syslogs for all scopone services

## Configuration Options

### Client Packages

Both client packages now support a `serverAddress` parameter:

```nix
# For React client
pkgs.callPackage ./nixos-modules/client-react.nix {
  serverAddress = "wss://server-scopone.gerryd.it/osteria";
}

# For Angular client
pkgs.callPackage ./nixos-modules/client-ng.nix {
  serverAddress = "wss://server-scopone.gerryd.it/osteria";
}
```

### NixOS Modules

Both client NixOS modules have a `serverAddress` option:

```nix
services.scopone-client-react = {
  enable = true;
  serverAddress = "wss://server-scopone.gerryd.it/osteria";
  # ... other options
};

services.scopone-client-ng = {
  enable = true;
  serverAddress = "wss://server-scopone.gerryd.it/osteria";
  # ... other options
};
```

## System Configuration

### /etc/nixos/apps/scopone.nix

```nix
{ config, pkgs, lib, inputs, ... }:

let
  # Build the React client package with the correct server address
  scopone-client-react-pkg = import "${inputs.scopone-ng-react}/nixos-modules/client-react.nix" {
    lib = lib;
    buildNpmPackage = pkgs.buildNpmPackage;
    nodejs = pkgs.nodejs;
    serverAddress = "wss://server-scopone.gerryd.it/osteria";
  };
in
{
  # Scopone Server - WebSocket game server
  services.scopone-server = {
    enable = true;
    package = pkgs.scopone-server;
    port = 65025;
  };

  # Scopone React Client - served via Caddy
  services.caddy.virtualHosts =
    (config.caddyLib.mkPrivateReverseProxy "server-scopone" 65025)
    // (config.caddyLib.mkPublicReverseProxyToAnubisInstance "server-scopone.gerryd.it" "server-scopone")
    // (config.caddyLib.mkWebservers
      scopone-client-react-pkg
      [ "scopone.gerryd.it" ]
    )
    // (config.caddyLib.mkPrivateWebserver
      scopone-client-react-pkg
      "scopone"
    )
    // (config.caddyLib.mkPublicReverseProxyToAnubisInstance "scopone.gerryd.it" "scopone");
}
```

### /etc/nixos/flake.nix additions

```nix
# Overlay to make scopone packages available
scopone-overlay = final: prev: {
  scopone-server = inputs.scopone-ng-react.packages.${system}.scopone-server;
  scopone-client-ng = inputs.scopone-ng-react.packages.${system}.scopone-client-ng;
  scopone-client-react = inputs.scopone-ng-react.packages.${system}.scopone-client-react;
};

# Modules
inputs.scopone-ng-react.nixosModules.scopone-server
inputs.scopone-ng-react.nixosModules.scopone-client-ng
inputs.scopone-ng-react.nixosModules.scopone-client-react
```

## Verification Results

### Server Status
```
● scopone-server.service - Scopone Card Game Server
     Active: active (running)
     Main PID: 247885 (scopone-in-memo)
     Memory: 9.2M
```

### Server Logs
```
Mar 12 10:32:16 ASUS scopone-in-memory-only[247885]: Scopone in memory (no database) started
Mar 12 10:32:16 ASUS scopone-in-memory-only[247885]: Server started
Mar 12 10:32:16 ASUS scopone-in-memory-only[247885]: Start Scopone
Mar 12 10:32:16 ASUS scopone-in-memory-only[247885]: Version 2.0.0
```

### Port Verification
- Port 65025: scopone-in-memory-only (server) ✓
- Port 80/443: caddy (serving React client) ✓

### HTTP Test
```
$ curl http://localhost:65025/
Home Page
```

## Known Issues

1. **SSL Certificate Errors**: Caddy is attempting to obtain SSL certificates for public domains but failing due to DNS configuration issues. This is expected for domains not yet properly configured.

2. **Angular Client**: Currently disabled in favor of React client. Can be enabled by modifying `/etc/nixos/apps/scopone.nix`.

## Build Hashes

| Package | npmDepsHash/vendorHash |
|---------|----------------------|
| scopone-server | sha256-RGiTwSGf3G/x7MmUP/CDDMMXY5En2E/k7m+h6OCsbaw= |
| scopone-client-ng | sha256-0akXGp8wBPk3YAQRgZXM9KVqmF3tErG1BSG5DkRaG1M= |
| scopone-client-react | sha256-JTzTOnKIstTkNVKN26YsqXUca2QGu6W7e5luSHFvy2Y= |

## Progress Log

### 2026-03-12 - Completion

1. **Initial Assessment**
   - Reviewed all existing Nix modules
   - Identified gaps in flake.nix exports (missing client-react)
   - Found existing configuration in /etc/nixos/apps/scopone.nix

2. **Package Fixes**
   - Updated flake.nix to export scopone-client-react package and module
   - Fixed default.nix to use go_1_24 (Go 1.18 was EOL)
   - Fixed client-ng.nix with correct npmDepsHash and rxjs paths
   - Fixed client-react.nix with proper scopone-rx-service integration
   - **Added `serverAddress` parameter to both client packages**

3. **Module Fixes**
   - Updated scopone-server.nix with user/group creation and security hardening
   - Updated scopone-client-react.nix to use package option and useNginx flag
   - **Updated both client NixOS modules with `serverAddress` option**

4. **System Integration**
   - Updated /etc/nixos/flake.nix to include all modules and overlay
   - Updated /etc/nixos/apps/scopone.nix to use Caddy instead of nginx
   - **Configured client to connect to `wss://server-scopone.gerryd.it/osteria`**
   - Successfully rebuilt system with `nixos-rebuild switch`

5. **Verification**
   - All packages build successfully
   - scopone-server.service is active and running on port 65025
   - Caddy is serving the React client on ports 80/443
   - Server responds with "Home Page" on HTTP requests
   - **Client built with correct WebSocket server address**

### 2026-03-12 - Server Address Configuration

Added the ability to configure the WebSocket server address for both client packages:

1. **client-react.nix** - Added `serverAddress` parameter (default: `"ws://localhost:65025/osteria"`)
2. **client-ng.nix** - Added `serverAddress` parameter (default: `"ws://localhost:65025/osteria"`)
3. **scopone-client-react.nix** - Added `serverAddress` option and uses `pkgs.callPackage` to create the package
4. **scopone-client-ng.nix** - Added `serverAddress` option and uses `pkgs.callPackage` to create the package
5. **/etc/nixos/apps/scopone.nix** - Updated to use `import` with explicit parameters to configure the server address as `wss://server-scopone.gerryd.it/osteria`
