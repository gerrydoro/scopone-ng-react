# Project Coding Rules (Non-Obvious Only)

- React client imports require `craco` handling; check `client-react/craco.config.js` for path mapping if imports fail.
- Shared library (`scopone-rx-service`) changes require immediate `npm run test` in that directory to ensure game model consistency.
- Use `client-react/tsconfig-works-for-service-test.json` when running tests that span client and service components.
- WebSocket message types are strictly defined in `scopone-rx-service/src/scopone-messages.ts`.
