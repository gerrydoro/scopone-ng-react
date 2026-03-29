# Gemini Context for Scopone-ng-react

This document provides context for the Gemini AI assistant to understand the `scopone-ng-react` project.

## Project Overview

This project is a web application for the Italian card game "Scopone". It allows four players to play the game in real-time. The application is structured as a monorepo containing a backend server and two frontend clients (one in Angular and one in React).

## Architecture

The project is composed of three main parts:

1.  **Backend Server**: A Go 1.24 application that uses WebSockets for real-time communication with the clients. It can be run with or without a MongoDB database for persistence. The server can also be deployed as an AWS Lambda function.

    ### Server Dependencies (Latest)
    - Go 1.24
    - `aws/aws-lambda-go` v1.50.0
    - `aws/aws-sdk-go` v1.55.8
    - `gorilla/websocket` v1.5.3
    - `spf13/viper` v1.21.0
    - `mongo-driver` v1.17.6

2.  **Frontend Clients**:
    *   **Angular Client**: Located in the `client-ng` directory (Angular 19.2.17)
    *   **React Client**: Located in the `client-react` directory (React 19.2.4)

    ### Angular Client Dependencies
    - Angular 19.2.17
    - Angular Material 19.2.17
    - RxJS 7.8.2
    - TypeScript 5.7.3

    ### React Client Dependencies
    - React 19.2.4
    - React DOM 19.2.4
    - MUI Material 7.3.9
    - MUI Icons 7.3.9
    - React Router DOM 7.13.1
    - RxJS 7.8.2
    - TypeScript 5.9.3

3.  **Shared Service**: A TypeScript library located in `scopone-rx-service`. This service uses RxJS 7.8.2 to manage communication with the backend server and is shared between the Angular and React clients.

## Getting Started

### Backend Server (Go)

The Go server code is located in the `server` directory.

**Build:**

*   **With MongoDB support:**
    ```bash
    cd server
    go build -o scopone-app ./src/cmd/scopone-mongo
    ```
*   **In-memory only (no database):**
    ```bash
    cd server
    go build -o scopone-app ./src/cmd/scopone-in-memory-only
    ```

**Run:**

*   If built with MongoDB support, set the `MONGO_CONNECTION` environment variable:
    ```bash
    cd server
    MONGO_CONNECTION="your-mongo-db-connection-string" ./scopone-app
    ```
*   If built for in-memory only:
    ```bash
    cd server
    ./scopone-app
    ```

**Test:**

```bash
cd server
go test ./...
```

### Angular Client

The Angular client code is in the `client-ng` directory.

**Run development server:**

```bash
cd client-ng
npm install
ng serve
```

**Build for production:**

```bash
cd client-ng
ng build
```

### React Client

The React client code is in the `client-react` directory.

**Run development server:**

```bash
cd client-react
npm install
npm run start
```

**Build for production:**

```bash
cd client-react
npm run build
```

### Shared Service (scopone-rx-service)

The shared service code is in the `scopone-rx-service` directory.

**Test:**

```bash
cd scopone-rx-service
npm install
npm run test
```

## Development Conventions

*   **Component-Based Architecture**: Both the Angular and React clients are built using a component-based architecture.
*   **Shared Logic**: The `scopone-rx-service` contains the core client-side logic for interacting with the backend. This promotes code reuse and consistency between the two clients.
*   **Nix Environments**: The project includes `flake.nix` and other Nix files, suggesting that development environments can be managed using Nix.

## Deployment

### Serverless Framework (v4)

The server can be deployed as an AWS Lambda function using Serverless Framework v4:

```bash
cd server
npm install
npx sls deploy
```

### NixOS Modules

The project provides NixOS modules for deployment:

```bash
nix build .#scopone-server
nix build .#scopone-client-ng
nix build .#scopone-client-react
```

## Recent Updates (2026)

All dependencies have been updated to their latest major versions:

- **Go Server**: Updated to Go 1.24 with latest dependencies
- **React Client**: Upgraded from React 17 to React 19.2.4
- **Angular Client**: Upgraded to Angular 19.2.17
- **MUI**: Upgraded from v4 to v7 (React client)
- **Serverless Framework**: Upgraded from v2 to v4
- **TypeScript**: Updated to 5.9.3 (React) and 5.7.3 (Angular)
