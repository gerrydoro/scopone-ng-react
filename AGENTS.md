# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Core Architecture
- **Server**: Go (Gorilla WebSocket or AWS Lambda).
- **Clients**: Angular 19.2 (`client-ng`) and React 19.2 (`client-react`).
- **Shared**: `scopone-rx-service` (TypeScript/RxJS) used by both clients.
- **Build/Deployment**: Nix Flakes for all components.

## Key Conventions & Gotchas
- React client uses `craco` for build configuration (`client-react/craco.config.js`).
- Shared service is the single source of truth for game models.
- Server supports in-memory and MongoDB modes (toggle via `MONGO_CONNECTION` env var).

## Commands
- Nix builds: `nix build .#<package>`
- Server (Go): `go build -o scopone-app ./src/cmd/...`
