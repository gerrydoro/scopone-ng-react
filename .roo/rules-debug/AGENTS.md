# Project Debug Rules (Non-Obvious Only)

- Server mode is determined by `MONGO_CONNECTION` environment variable (in-memory if unset).
- Client server address is configured via `REACT_APP_SERVER_ADDRESS` (.env) or NixOS module `serverAddress`.
