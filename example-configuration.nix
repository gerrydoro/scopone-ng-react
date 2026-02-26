{ pkgs, ... }:

{
  imports = [
    ./scopone-server.nix
  ];

  # Scopone server configuration
  services.scopone-server = {
    enable = true;
    package = pkgs.callPackage ./default.nix { };
    port = 8080;
    
    # MongoDB connection (optional - if null, runs in in-memory mode)
    # mongoConnection = "mongodb://user:password@localhost:27017/scopone?retryWrites=true&w=majority";
    
    # Or use an environment file for sensitive data
    # environmentFile = "/etc/scopone-server/.env";
    
    extraEnvironment = {
      # Add any additional environment variables here
      SERVER_NAME = "scopone";
    };
  };

  # Allow incoming connections on port 8080
  networking.firewall.allowedTCPPorts = [ 8080 ];

  system.stateVersion = "23.05";
}
