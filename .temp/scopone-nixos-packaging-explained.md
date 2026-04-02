# Scopone React Client - NixOS Packaging Explained

## Table of Contents

1. [Overview](#overview)
2. [How the React Client is Packaged](#how-the-react-client-is-packaged)
3. [How It's Imported in Your Configuration](#how-its-imported-in-your-configuration)
4. [What Happens During Rebuild](#what-happens-during-rebuild)
5. [Why It's Not a "Service" Like the Server](#why-its-not-a-service-like-the-server)
6. [Key Differences: Server vs Client](#key-differences-server-vs-client)

---

## Overview

The Scopone project has two main components deployed on NixOS:

| Component | Type | Deployment Method |
|-----------|------|-------------------|
| **Scopone Server** (Go) | System Service | `services.scopone-server` |
| **Scopone Client** (React) | Static Files | Served via Caddy |

---

## How the React Client is Packaged

### 1. Nix Expression (`nixos-modules/client-react.nix`)

The React client is packaged as a **Nix derivation** that:

```nix
{
  lib,
  buildNpmPackage,
  nodejs,
  serverAddress ? null,
}:
let
  scoponeRxServiceSrc = lib.cleanSourceWith { ... };
in
buildNpmPackage rec {
  pname = "scopone-client-react";
  version = "0.2.1";
  
  # Source code from the repository
  src = lib.cleanSourceWith {
    src = ../client-react;
    # Filter to include only necessary files
  };
  
  postPatch = ''
    # Copy shared service code
    cp -r ${scoponeRxServiceSrc}/* ../scopone-rx-service/
    
    # Create .env.production with server address
    cat > .env.production << ENVFILE
    REACT_APP_SERVER_ADDRESS=${serverAddress}
    ENVFILE
  '';
  
  # Build the React app
  buildPhase = ''
    npm run build
  '';
  
  # Install to Nix store
  installPhase = ''
    mkdir -p $out
    cp -r build/* $out/
  '';
}
```

**Key Points:**
- Uses `buildNpmPackage` to build the React app
- Runs `npm run build` to create production bundle
- Copies the `build/` folder to the Nix store (`$out`)
- The result is a **static file tree** (HTML, CSS, JS)

### 2. Flake Export (`flake.nix`)

```nix
outputs = { self, nixpkgs, flake-utils }:
  flake-utils.lib.eachDefaultSystem (system:
    {
      packages.scopone-client-react = pkgs.callPackage ./nixos-modules/client-react.nix { };
    }
  ) // {
    nixosModules.scopone-client-react = import ./nixos-modules/scopone-client-react.nix;
  };
```

**Two exports:**
1. `packages.scopone-client-react` - The built package
2. `nixosModules.scopone-client-react` - The NixOS module (optional service wrapper)

---

## How It's Imported in Your Configuration

### Your Flake (`/etc/nixos/flake.nix`)

```nix
{
  inputs = {
    scopone-ng-react.url = "github:gerrydoro/scopone-ng-react";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      # Create overlay to make package available
      main-overlay = final: prev: {
        scopone-client-react = inputs.scopone-ng-react.packages.${system}.scopone-client-react;
      };
    in
    {
      nixosConfigurations.ASUS = nixpkgs.lib.nixosSystem {
        modules = [
          ./configuration.nix
          inputs.scopone-ng-react.nixosModules.scopone-client-react  # Optional module
          {
            nixpkgs.overlays = [ main-overlay ];  # Makes package available as pkgs.scopone-client-react
          }
        ];
      };
    };
}
```

### Your App Configuration (`/etc/nixos/apps/scopone.nix`)

```nix
{
  config,
  pkgs,
  inputs,
  ...
}:
{
  services.caddy.virtualHosts =
    # This serves the React client static files
    (config.caddyLib.mkPrivateWebserver
      inputs.scopone-ng-react.packages.${pkgs.system}.scopone-client-react  # ← The package
      "scopone"  # ← hostname prefix (becomes scopone.gerryd.myaddr.io)
    );
}
```

**What happens:**
1. `inputs.scopone-ng-react.packages.${pkgs.system}.scopone-client-react` references the **built package** from the flake
2. `mkPrivateWebserver` creates a Caddy virtualHost configuration
3. Caddy serves the static files from the Nix store path

---

## What Happens During Rebuild

### Step-by-Step Rebuild Process

```bash
sudo nixos-rebuild switch --flake .#ASUS
```

1. **Flake Input Resolution**
   ```
   → Reads /etc/nixos/flake.lock
   → Resolves scopone-ng-react to specific commit (e.g., 237d20f)
   → Downloads source from GitHub if not cached
   ```

2. **Package Build** (if not cached)
   ```
   → Evaluates nixos-modules/client-react.nix
   → Downloads Node.js dependencies
   → Runs npm install
   → Runs npm run build
   → Creates production bundle in /nix/store/xxxx-scopone-client-react-0.2.1/
   ```

3. **Configuration Generation**
   ```
   → Evaluates apps/scopone.nix
   → Generates Caddy configuration
   → Caddy virtualHost points to new /nix/store path
   ```

4. **Activation**
   ```
   → switch-to-configuration runs
   → Caddy service reloads
   → Caddy now serves files from NEW /nix/store path
   → Old /nix/store path remains (garbage collected later)
   ```

### Visual Flow

```
┌─────────────────────────────────────────────────────────────────┐
│  GitHub: gerrydoro/scopone-ng-react@main                       │
│  (Latest commit with your changes)                              │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│  Nix Flake Evaluation                                           │
│  inputs.scopone-ng-react.packages.x86_64-linux.scopone-client   │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│  Nix Build                                                      │
│  - npm install                                                  │
│  - npm run build                                                │
│  - Output: /nix/store/abcd1234-scopone-client-react-0.2.1/      │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│  Caddy Configuration                                            │
│  scopone.gerryd.myaddr.io {                                     │
│    root /nix/store/abcd1234-scopone-client-react-0.2.1/         │
│    file_server                                                  │
│  }                                                              │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│  Caddy Service Reload                                           │
│  → Reads new config                                             │
│  → Serves files from NEW store path                             │
└─────────────────────────────────────────────────────────────────┘
```

---

## Why It's Not a "Service" Like the Server

### Scopone Server (`services.scopone-server`)

```nix
# In nixos-modules/scopone-server.nix
{ config, lib, pkgs, ... }:
let
  cfg = config.services.scopone-server;
in
{
  options.services.scopone-server = {
    enable = lib.mkEnableOption "Scopone server";
    package = lib.mkOption { type = lib.types.package; };
    port = lib.mkOption { type = lib.types.port; default = 8080; };
    # ... more options
  };

  config = lib.mkIf cfg.enable {
    systemd.services.scopone-server = {
      description = "Scopone WebSocket Game Server";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/scopone-in-memory-only";
        # ... service configuration
      };
    };
    
    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
```

**This IS a service because:**
- Runs as a **long-running process** (daemon)
- Managed by **systemd** (start, stop, restart, status)
- Listens on a **network port**
- Has **state** (game sessions, player connections)
- Needs **lifecycle management** (restart on crash, start on boot)

### Scopone Client (React)

**This is NOT a service because:**
- It's **static files** (HTML, CSS, JavaScript)
- **No running process** - just files on disk
- **No state** - stateless files served to browsers
- **No lifecycle** - files don't start/stop
- **Caddy is the service** - Caddy serves the files

### Analogy

| Component | Analogy | NixOS Type |
|-----------|---------|------------|
| **Scopone Server** | Restaurant kitchen (cooks food, runs continuously) | `systemd.service` |
| **Scopone Client** | Menu cards (static, just displayed) | Static files in `/nix/store` |
| **Caddy** | Waiter (serves menu cards to customers) | `systemd.service` |

---

## Key Differences: Server vs Client

| Aspect | Server (Go) | Client (React) |
|--------|-------------|----------------|
| **Type** | Executable binary | Static files |
| **Nix Output** | `/nix/store/xxx-scopone-server/bin/scopone-app` | `/nix/store/xxx-scopone-client-react/index.html` |
| **Runtime** | Runs as process | Served by Caddy |
| **systemd** | Yes (`scopone-server.service`) | No |
| **Port** | Listens on 65025 | Served on Caddy's port (443) |
| **State** | Maintains game state | Stateless |
| **Configuration** | `services.scopone-server.*` | Caddy virtualHost config |
| **Updates** | Restart service | Reload Caddy config |

---

## Why Your Configuration Uses `inputs.scopone-ng-react.packages.*` Directly

Instead of using the NixOS module (`services.scopone-client-react`), your configuration directly references the package:

```nix
# Your approach (direct package reference)
services.caddy.virtualHosts =
  (config.caddyLib.mkPrivateWebserver
    inputs.scopone-ng-react.packages.${pkgs.system}.scopone-client-react
    "scopone"
  );

# Alternative (using NixOS module - if it existed)
services.scopone-client-react = {
  enable = true;
  package = inputs.scopone-ng-react.packages.${pkgs.system}.scopone-client-react;
  hostname = "scopone.gerryd.myaddr.io";
};
```

**Why direct reference?**
1. **Simpler** - No need for extra NixOS module abstraction
2. **More flexible** - You control exactly how Caddy serves it
3. **Caddy-centric** - Your setup is built around Caddy, not nginx/systemd
4. **No extra options needed** - The package is all you need

---

## Troubleshooting: Why Changes Don't Appear

### Common Issues

1. **Flake Lock Not Updated**
   ```bash
   # Check current lock
   cat /etc/nixos/flake.lock | grep -A 5 scopone-ng-react
   
   # Update to latest
   sudo nix flake update scopone-ng-react
   ```

2. **Build Cache**
   ```bash
   # Force rebuild
   sudo nixos-rebuild switch --flake .#ASUS --rebuild
   ```

3. **Browser Cache** (MOST COMMON)
   - Browser caches `index.html` and JS bundles
   - Solution: Hard refresh (Ctrl+Shift+R) or add cache-control headers

4. **Caddy Not Reloading**
   ```bash
   sudo systemctl restart caddy
   ```

### Debug Commands

```bash
# Check which package version is deployed
cat /etc/caddy/caddy_config | grep scopone-client-react

# Check what's in the deployed package
ls -la /nix/store/*-scopone-client-react-*/

# Check current flake input
nix flake info /etc/nixos#nixosConfigurations.ASUS.inputs.scopone-ng-react

# Check bundle hash in browser vs store
curl -s https://scopone.gerryd.myaddr.io/ | grep -o "main\.[a-z0-9]*\.js"
ls /nix/store/*-scopone-client-react-*/static/js/
```

---

## Summary

1. **React Client** = Static files built by Nix, served by Caddy
2. **Go Server** = Systemd service running as daemon
3. **Flake inputs** point to GitHub, lock file pins specific commit
4. **Rebuild** = Build new package → Update Caddy config → Reload Caddy
5. **Not a service** because it's just files, not a running process

The key insight: **The React app is a *product* (files), not a *process* (service).**
