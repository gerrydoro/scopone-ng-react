{ config, pkgs, ... }:

{
  imports = [
    ./scopone-server.nix
  ];

  services.scopone-server = {
    enable = true;
    package = pkgs.scopone-server;
    port = 8080;
  };

  networking.firewall.allowedTCPPorts = [ 8080 ];

  system.stateVersion = "24.05";
}
