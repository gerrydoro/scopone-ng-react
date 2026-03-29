# Scopone Go Server

## Overview

The Scopone server is a Go application (Go 1.24+) that implements a WebSocket server for the Scopone card game.

## Dependencies

### Core Dependencies (Latest Versions)

| Package | Version | Description |
|---------|---------|-------------|
| `aws/aws-lambda-go` | v1.50.0 | AWS Lambda support |
| `aws/aws-sdk-go` | v1.55.8 | AWS SDK |
| `gorilla/websocket` | v1.5.3 | WebSocket implementation |
| `spf13/viper` | v1.21.0 | Configuration management |
| `mongo-driver` | v1.17.6 | MongoDB driver |
| `fnproject/fdk-go` | v0.0.27 | Fn Project FDK |

## Node Modules

node_modules and package.json are present only because the serverless framework is installed in this folder to speed up the
deployment. Otherwise, any time we deploy, we should download it since the serverless command must be launched from
within this folder in order for it to work properly.

### Serverless Framework

- **serverless**: ^4.23.0 (Latest v4)
