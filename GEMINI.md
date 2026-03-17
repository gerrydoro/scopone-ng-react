# Gemini Context for Scopone-ng-react

This document provides context for the Gemini AI assistant to understand the `scopone-ng-react` project.

## Project Overview

This project is a web application for the Italian card game "Scopone". It allows four players to play the game in real-time. The application is structured as a monorepo containing a backend server and two frontend clients (one in Angular and one in React).

## Architecture

The project is composed of three main parts:

1.  **Backend Server**: A Go application that uses WebSockets for real-time communication with the clients. It can be run with or without a MongoDB database for persistence. The server can also be deployed as an AWS Lambda function.

2.  **Frontend Clients**:
    *   **Angular Client**: Located in the `client-ng` directory.
    *   **React Client**: Located in the `client-react` directory.

3.  **Shared Service**: A TypeScript library located in `scopone-rx-service`. This service uses RxJS to manage communication with the backend server and is shared between the Angular and React clients.

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
ng serve
```

**Build for production:**

```bash
cd client-ng
ng build --prod
```

### React Client

The React client code is in the `client-react` directory.

**Run development server:**

```bash
cd client-react
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
npm run test
```

## Development Conventions

*   **Component-Based Architecture**: Both the Angular and React clients are built using a component-based architecture.
*   **Shared Logic**: The `scopone-rx-service` contains the core client-side logic for interacting with the backend. This promotes code reuse and consistency between the two clients.
*   **Nix Environments**: The project includes `flake.nix` and other Nix files, suggesting that development environments can be managed using Nix.
