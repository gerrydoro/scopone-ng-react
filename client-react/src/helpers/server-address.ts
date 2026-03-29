/**
 * Get the WebSocket server address for the Scopone game server.
 * 
 * Priority:
 * 1. If REACT_APP_SERVER_ADDRESS is explicitly set, use it
 * 2. Otherwise, derive from current window location (for production)
 * 3. Fall back to localhost for development
 */
export function getServerAddress(): string {
  // Check if environment variable is explicitly set
  const envAddress = process.env.REACT_APP_SERVER_ADDRESS;
  if (envAddress && envAddress.trim() !== '') {
    return envAddress;
  }

  // In browser environment, derive from current location
  if (typeof window !== 'undefined' && window.location) {
    const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
    const host = window.location.host;
    
    // For the main domain (scopone.gerryd.myaddr.io), connect to the server port
    // The server runs on port 65025
    if (host.includes('gerryd.myaddr.io') || host.includes('gerryd.it')) {
      const serverHost = host.replace('scopone.', 'server-scopone.');
      return `${protocol}//${serverHost}/osteria`;
    }
    
    // Default: use same host as the client
    return `${protocol}//${host}/osteria`;
  }

  // Default fallback for development
  return 'ws://localhost:65025/osteria';
}
