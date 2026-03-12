# Scopone NG React - Project Context

## Project Overview

**Scopone** is a digital implementation of Scopone, a traditional Italian card game. The application supports multiplayer gameplay with 4 players per table and allows multiple concurrent games.

### Architecture

The project is a full-stack application with the following components:

| Component | Technology | Location | Description |
|-----------|------------|----------|-------------|
| **Server** | Go 1.18+ | `server/` | WebSocket server with MongoDB support (or in-memory mode) |
| **Client (Angular)** | Angular 19 | `client-ng/` | Angular-based web client |
| **Client (React)** | React 17 | `client-react/` | React-based web client |
| **Shared Service** | TypeScript/RxJS | `scopone-rx-service/` | Shared service library used by both clients |
| **CI/CD** | Serverless Framework | `serverless-cd/` | Deployment scripts for AWS Lambda and S3 |
| **NixOS Modules** | Nix/NixOS | `nixos-modules/` | Nix packages and NixOS modules for deployment |

### Communication

- **Protocol**: WebSocket
- **Server Libraries**: Gorilla WebSocket (standard mode), AWS Lambda (serverless mode)
- **Client Libraries**: RxJS for reactive streams

## Building and Running

### Nix/NixOS (Recommended)

The project provides Nix flakes and NixOS modules for reproducible builds and deployment.

#### Build Packages

```bash
# Build server
nix build .#scopone-server

# Build Angular client
nix build .#scopone-client-ng

# Build React client
nix build .#scopone-client-react
```

#### NixOS Module Usage

Add to your flake inputs:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  scopone-ng-react.url = "github:gerrydoro/scopone-ng-react";
};
```

Enable services in your configuration:

```nix
{ config, pkgs, ... }:
{
  # Scopone Server
  services.scopone-server = {
    enable = true;
    package = pkgs.scopone-server;
    port = 8080;
    # Optional MongoDB connection
    # mongoConnection = "mongodb://user:password@localhost:27017/scopone";
  };

  # Scopone React Client
  services.scopone-client-react = {
    enable = true;
    package = pkgs.scopone-client-react;
    port = 65026;
    serverAddress = "ws://localhost:8080/osteria";
  };

  # Scopone Angular Client
  services.scopone-client-ng = {
    enable = true;
    package = pkgs.scopone-client-ng;
    port = 65027;
    serverAddress = "ws://localhost:8080/osteria";
  };
}
```

### Go Server (Standalone)

```bash
cd server

# Build in-memory version (no MongoDB)
go build -o scopone-app ./src/cmd/scopone-in-memory-only

# Build MongoDB version
go build -o scopone-app ./src/cmd/scopone-mongo

# Run
./scopone-app
```

#### Docker

```bash
cd server
docker build -t scopone-server -f Dockerfile-minimal-mongo .
docker run -p 8080:8080 scopone-server
```

### Angular Client

```bash
cd client-ng
npm install
npm run start        # Development
npm run build        # Production
```

### React Client

```bash
cd client-react
npm install
npm run start        # Development (uses craco)
npm run build        # Production
```

### Shared Service (scopone-rx-service)

```bash
cd scopone-rx-service
npm install
npm run test         # Run tests
```

## Testing

### Server Tests

```bash
cd server
go test ./...
```

### Shared Service Tests

```bash
cd scopone-rx-service
npm run test
```

### Client Tests

```bash
# Angular
cd client-ng
npm run test

# React
cd client-react
npm run test
```

## Development Conventions

### Go Server

- **Go Version**: 1.18+ (Nix uses go_1_24)
- **Module**: `go-scopone`
- **Testing**: Standard Go testing with `go test`
- **Static Analysis**: Uses `staticcheck` (config in `server/staticcheck.conf`)

### TypeScript Clients & Service

- **Angular Client**: TypeScript ~5.7, Angular 19
- **React Client**: TypeScript ~4.1, React 17
- **Shared Service**: TypeScript ~5.7, RxJS ~7.8
- **Testing**: 
  - Angular: Karma + Jasmine
  - React: Jest + Testing Library
  - Service: Mocha + Chai

### Nix/NixOS

- **Flake-based**: Uses Nix flakes for reproducible builds
- **Package Structure**:
  - `nixos-modules/default.nix` - Server package (Go module)
  - `nixos-modules/client-ng.nix` - Angular client package
  - `nixos-modules/client-react.nix` - React client package
  - `nixos-modules/scopone-server.nix` - Server NixOS module
  - `nixos-modules/scopone-client-ng.nix` - Angular client NixOS module
  - `nixos-modules/scopone-client-react.nix` - React client NixOS module

### Security Hardening (NixOS Modules)

The server module includes systemd security hardening:

- `NoNewPrivileges = true`
- `PrivateTmp = true`
- `ProtectSystem = "strict"`
- `ProtectHome = true`
- Network restrictions to IPv4/IPv6 only
- Dedicated service user/group

## Project Structure

```
scopone-ng-react/
├── server/                 # Go WebSocket server
│   ├── src/
│   │   ├── cmd/           # Server entry points
│   │   │   ├── scopone-in-memory-only/
│   │   │   └── scopone-mongo/
│   │   └── server/        # Core server logic
│   ├── go.mod
│   └── serverless.yml     # Serverless Framework config
├── client-ng/             # Angular 19 client
│   ├── src/
│   ├── angular.json
│   └── package.json
├── client-react/          # React 17 client
│   ├── src/
│   ├── craco.config.js
│   └── package.json
├── scopone-rx-service/    # Shared TypeScript service
│   ├── src/
│   │   ├── lib/          # Core service logic
│   │   └── test/         # Integration tests
│   └── package.json
├── serverless-cd/         # CI/CD deployment scripts
│   ├── client-ng-s3/
│   ├── client-react-s3/
│   └── server-lambda/
└── nixos-modules/         # Nix packages & NixOS modules
    ├── default.nix        # Server package
    ├── client-ng.nix      # Angular client package
    ├── client-react.nix   # React client package
    ├── scopone-server.nix
    ├── scopone-client-ng.nix
    └── scopone-client-react.nix
```

## Configuration

### Server Configuration

| Environment Variable | Description |
|---------------------|-------------|
| `MONGO_CONNECTION` | MongoDB connection string (optional - if not set, runs in-memory) |
| `GIN_MODE` | Gin framework mode (`release` for production) |

### Client Configuration

**Angular** (`client-ng/src/environments/`):
- `environment.ts` - Development
- `environment.prod.ts` - Production
- Key property: `serverAddress`

**React** (`.env.*` files):
- `.env.development` - Development
- `.env.production` - Production
- Key variable: `REACT_APP_SERVER_ADDRESS`

## Deployment

### AWS Lambda (Serverless)

```bash
cd server
env GOOS=linux go build -ldflags="-s -w" -o ./bin/handleRequest ./src/server/srvlambda
npx sls deploy
```

### Google App Engine

See `server/command-gcloud.md` for GAE deployment instructions.

### S3 Static Hosting (Clients)

```bash
# Angular
cd serverless-cd/client-ng-s3
bash build-deploy-ng-front-end.sh

# React
cd serverless-cd/client-react-s3
bash build-deploy-react-front-end.sh
```

## Game Flow

1. Player launches the web application
2. Player enters their name
3. Player joins or creates a game table
4. When 4 players join, the game can start
5. Server shuffles a 40-card deck and deals 10 cards to each player
6. Players take turns playing cards
7. When all cards are played, the hand result is shown
8. Players can continue to the next hand or stop
9. If a player disconnects, the game pauses until they reconnect

## Key Files

| File | Purpose |
|------|---------|
| `flake.nix` | Nix flake definition with package and module exports |
| `scopone-workspace.code-workspace` | VSCode workspace configuration |
| `server/go.mod` | Go module definition |
| `nixos-modules/README.md` | Detailed NixOS module documentation |
| `NIX_MODULES_PROGRESS.md` | Progress tracking for Nix module development |

## Known Issues

1. **SSL Certificate Errors**: Caddy may fail to obtain SSL certificates for domains without proper DNS configuration
2. **Angular Client**: Currently less maintained than React client (Angular was upgraded to v19, but React is the primary client)
3. **Go Dependencies**: Server uses Go 1.18 in `go.mod`, but Nix builds use go_1_24 for compatibility

## Related Documentation

- [NixOS Module Progress](./NIX_MODULES_PROGRESS.md) - Tracks Nix module development status
- [NixOS Module README](./nixos-modules/README.md) - Detailed server module documentation
- [Server README](./server/readme.md) - Server implementation details
- [Agent Instructions](./AGENT.md) - Instructions for AI agents working on this project
