# Scopone Server - NixOS Module

This directory contains the NixOS module and Nix expressions for deploying the Scopone card game server.

## Quick Start

### Using Flakes (Recommended)

1. Add this repository to your NixOS configuration's flake inputs:

```nix
{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    scopone-ng-react.url = "github:gerrydoro/scopone-ng-react";
  };

  outputs = { self, nixpkgs, scopone-ng-react }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        scopone-ng-react.nixosModules.scopone-server
      ];
    };
  };
}
```

2. Enable the service in your configuration:

```nix
{ config, pkgs, ... }:

{
  services.scopone-server = {
    enable = true;
    package = pkgs.scopone-server;
    port = 8080;
    # Optional: MongoDB connection
    # mongoConnection = "mongodb://user:password@localhost:27017/scopone";
  };
}
```

3. Rebuild your system:

```bash
sudo nixos-rebuild switch
```

### Without Flakes

1. Copy the module files to your configuration:

```bash
cp -r nixos-modules /etc/nixos/scopone-server
```

2. Import the module in your configuration:

```nix
{ config, pkgs, ... }:

{
  imports = [ ./scopone-server/scopone-server.nix ];

  services.scopone-server = {
    enable = true;
    package = pkgs.callPackage ./scopone-server/default.nix { };
    port = 8080;
  };
}
```

## Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `services.scopone-server.enable` | boolean | `false` | Enable the Scopone server |
| `services.scopone-server.package` | package | required | The Scopone server package |
| `services.scopone-server.host` | string | `"0.0.0.0"` | Host address to bind to |
| `services.scopone-server.port` | port | `8080` | Port to listen on |
| `services.scopone-server.mongoConnection` | nullOr string | `null` | MongoDB connection string |
| `services.scopone-server.environmentFile` | nullOr path | `null` | Path to environment file |
| `services.scopone-server.extraEnvironment` | attrs | `{}` | Additional environment variables |

## Usage Examples

### In-Memory Mode (No Database)

```nix
services.scopone-server = {
  enable = true;
  package = pkgs.scopone-server;
  port = 8080;
  # No mongoConnection - runs in in-memory mode
};
```

### With MongoDB

```nix
services.scopone-server = {
  enable = true;
  package = pkgs.scopone-server;
  port = 8080;
  mongoConnection = "mongodb://user:password@localhost:27017/scopone?retryWrites=true&w=majority";
};
```

### Using Environment File for Sensitive Data

Create `/etc/scopone-server/.env`:

```bash
MONGO_CONNECTION="mongodb://user:password@localhost:27017/scopone"
```

Then configure:

```nix
services.scopone-server = {
  enable = true;
  package = pkgs.scopone-server;
  port = 8080;
  environmentFile = "/etc/scopone-server/.env";
};
```

## Building the Package

### With Flakes

```bash
nix build github:gerrydoro/scopone-ng-react#scopone-server
```

### Without Flakes

```bash
nix-build -E 'with import <nixpkgs> { }; callPackage ./nixos-modules/default.nix { }'
```

## Service Management

Once enabled, manage the service with systemd:

```bash
# Check status
systemctl status scopone-server

# View logs
journalctl -u scopone-server -f

# Restart service
sudo systemctl restart scopone-server

# Stop service
sudo systemctl stop scopone-server
```

## Firewall

The module automatically opens the configured port in the firewall. If you manage your firewall manually, ensure port 8080 (or your configured port) is open:

```nix
networking.firewall.allowedTCPPorts = [ 8080 ];
```

## Security Hardening

The systemd service includes security hardening:

- `NoNewPrivileges` - Prevents privilege escalation
- `PrivateTmp` - Uses private /tmp directory
- `ProtectSystem` - Makes system directories read-only
- `ProtectHome` - Restricts access to home directories
- Network restrictions to IPv4/IPv6 only

## Development

To test changes to the NixOS module:

1. Build the package:
   ```bash
   nix-build nixos-modules/default.nix
   ```

2. Test in a VM:
   ```bash
   nix-build '<nixpkgs/nixos>' -A vm --arg configuration '{ config, pkgs, ... }: {
     imports = [ ./nixos-modules/scopone-server.nix ];
     services.scopone-server.enable = true;
     services.scopone-server.package = pkgs.callPackage ./nixos-modules/default.nix { };
   }'
   ```

## Troubleshooting

### Vendor Hash Mismatch

If Go dependencies change, update the `vendorHash` in `default.nix`:

```bash
nix-build nixos-modules/default.nix
# Copy the expected hash from the error message
```

### MongoDB Connection Issues

Ensure MongoDB is running and accessible:

```bash
systemctl status mongodb
```

Check the connection string format and credentials.

### Port Already in Use

If port 8080 is already in use, change it:

```nix
services.scopone-server.port = 8081;
```

## License

Same as the main Scopone project.
