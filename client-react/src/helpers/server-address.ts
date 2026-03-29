/**
 * Get the WebSocket server address for the Scopone game server.
 *
 * The server address is derived from the current browser location:
 * - Same protocol (wss for https, ws for http)
 * - Same port as the client
 * - "server-" prefix added to the hostname
 *
 * Examples:
 * - https://scopone.gerryd.myaddr.io/ → wss://server-scopone.gerryd.myaddr.io/osteria
 * - https://bestscopone.it/ → wss://server-bestscopone.it/osteria
 * - http://localhost:3000/ → ws://server-localhost:3000/osteria
 *
 * Can be overridden by setting REACT_APP_SERVER_ADDRESS environment variable.
 */
export function getServerAddress(): string {
  // Check if environment variable is explicitly set (override)
  const envAddress = process.env.REACT_APP_SERVER_ADDRESS;
  if (envAddress && envAddress.trim() !== '') {
    return envAddress;
  }

  // In browser environment, derive from current location
  if (typeof window !== 'undefined' && window.location) {
    const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
    const hostname = window.location.hostname;
    const port = window.location.port;

    // Add "server-" prefix to the hostname
    const serverHostname = `server-${hostname}`;

    // Include port if specified (omit for standard ports 80/443)
    const serverPort = port ? `:${port}` : '';

    return `${protocol}//${serverHostname}${serverPort}/osteria`;
  }

  // Default fallback for development
  return 'ws://server-localhost:65025/osteria';
}
