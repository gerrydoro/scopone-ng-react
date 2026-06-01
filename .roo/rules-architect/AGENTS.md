# Project Architecture Rules (Non-Obvious Only)

- WebSocket communication is the primary integration point.
- Server supports two modes: standalone Go (Gorilla) or AWS Lambda (Serverless).
- NixOS modules provide the production deployment wrapper including systemd hardening.
