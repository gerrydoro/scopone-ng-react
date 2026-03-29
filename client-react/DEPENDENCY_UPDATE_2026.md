# Dependency Update Summary - March 2026

## Overview

All project dependencies have been updated to their latest stable versions across the entire monorepo.

## Updated Packages

### Server (Go)

| Package | Old Version | New Version |
|---------|-------------|-------------|
| Go | 1.18 | **1.24** |
| aws/aws-lambda-go | v1.37.0 | **v1.50.0** |
| aws/aws-sdk-go | v1.44.209 | **v1.55.8** |
| gorilla/websocket | v1.5.0 | **v1.5.3** |
| spf13/viper | v1.15.0 | **v1.21.0** |
| mongo-driver | v1.11.2 | **v1.17.6** |
| serverless (npm) | ^2.70.0 | **^4.23.0** |

### React Client

| Package | Old Version | New Version |
|---------|-------------|-------------|
| react/react-dom | 19.2.4 | **19.2.4** (already latest) |
| @mui/material | 6.4.6 | **7.3.9** |
| @mui/icons-material | 6.4.6 | **7.3.9** |
| react-router-dom | 7.13.1 | **7.13.1** (already latest) |
| rxjs | 7.8.2 | **7.8.2** (already latest) |
| typescript | 5.9.3 | **5.9.3** (already latest) |

### Angular Client

| Package | Old Version | New Version |
|---------|-------------|-------------|
| @angular/* | 19.2.0 | **19.2.17** |
| rxjs | 7.8.2 | **7.8.2** (already latest) |
| typescript | 5.7.3 | **5.7.3** (already latest) |

### Shared Service (scopone-rx-service)

| Package | Old Version | New Version |
|---------|-------------|-------------|
| rxjs | 7.8.0 | **7.8.2** |
| tslib | 2.6.0 | **2.8.1** |
| ws | 6.2.2 | **8.18.2** |
| mocha | 9.2.0 | **11.7.5** |
| ts-node | 8.3.0 | **10.9.2** |
| typescript | 5.7.0 | **5.7.3** |

### Serverless CD

| Package | Old Version | New Version |
|---------|-------------|-------------|
| serverless | 2.31.0 | **4.23.0** |

## Code Changes

### React Client

1. **MUI v7 Compatibility**
   - Updated `@mui/material` and `@mui/icons-material` to v7.3.9
   - Fixed `ListItem` → `ListItemButton` component migration
   - Added `Theme` type to `makeStyles` usage

2. **web-vitals v5 API**
   - Updated from `getCLS, getFID...` to `onCLS, onFCP...` API
   - Removed deprecated `onFID` (replaced with `onINP` in v5, omitted for simplicity)

3. **Card Component**
   - Added `height` prop to `ICardProps` interface

### NixOS Modules

Updated vendor hashes for all packages:
- `nixos-modules/default.nix`: `vendorHash` updated
- `nixos-modules/client-ng.nix`: `npmDepsHash` updated
- `nixos-modules/client-react.nix`: `npmDepsHash` updated

## Verification

All builds completed successfully:

```bash
# Go tests
✓ go-scopone/src/game-logic/deck
✓ go-scopone/src/game-logic/player
✓ go-scopone/src/game-logic/scopone
✓ go-scopone/src/game-logic/team

# Nix builds
✓ nix build .#scopone-server
✓ nix build .#scopone-client-ng
✓ nix build .#scopone-client-react

# npm builds
✓ client-react: npm run build
✓ client-ng: npm run build
```

## Breaking Changes

### Serverless Framework v4
- Configuration files may need updates for v4 syntax
- Review `serverless.yml` files for compatibility

### MUI v7 (React)
- Some component APIs may have changed
- Check MUI v7 migration guide for details

## Files Modified

- `server/go.mod` - Go dependencies
- `server/go.sum` - Go checksums
- `server/package.json` - Serverless Framework
- `client-react/package.json` - React dependencies
- `client-react/src/components/card/card.tsx` - Added height prop
- `client-react/src/components/game-list/game-list.tsx` - MUI v7 migration
- `client-react/src/components/style-material-ui.ts` - Theme type
- `client-react/src/reportWebVitals.ts` - web-vitals v5 API
- `client-ng/package.json` - Angular dependencies
- `scopone-rx-service/package.json` - Service dependencies
- `serverless-cd/package.json` - Serverless Framework
- `nixos-modules/default.nix` - vendorHash
- `nixos-modules/client-ng.nix` - npmDepsHash
- `nixos-modules/client-react.nix` - npmDepsHash

## Documentation Updated

- `README.md` - Version references
- `server/readme.md` - Go dependencies
- `client-react/README.md` - React dependencies
- `client-ng/README.md` - Angular dependencies
- `nixos-modules/README.md` - Package versions
- `QWEN.md` - All version references
- `GEMINI.md` - Created with full dependency info
- `serverless-cd/readme.md` - Deployment info

## Date

March 29, 2026
