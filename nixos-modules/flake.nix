{
  description = "Scopone card game server - NixOS module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.scopone-server = pkgs.callPackage ./default.nix { };
        defaultPackage = self.packages.${system}.scopone-server;
      }
    ) // {
      nixosModules.scopone-server = import ./scopone-server.nix;
      
      nixosConfigurations.example = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./example-configuration.nix
          {
            nixpkgs.overlays = [
              (final: prev: {
                scopone-server = self.packages.${final.system}.scopone-server;
              })
            ];
          }
        ];
      };
    };
}
