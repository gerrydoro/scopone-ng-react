{
  description = "Scopone card game";

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
        packages.scopone-server = pkgs.callPackage ./nixos-modules/default.nix { };
        packages.scopone-client-ng = pkgs.callPackage ./nixos-modules/client-ng.nix { };
        packages.scopone-client-react = pkgs.callPackage ./nixos-modules/client-react.nix { nodejs = pkgs.nodejs_18; };
        defaultPackage = self.packages.${system}.scopone-server;
      }
    ) // {
      nixosModules.scopone-server = import ./nixos-modules/scopone-server.nix;
      nixosModules.scopone-client-ng = import ./nixos-modules/scopone-client-ng.nix;
      nixosModules.scopone-client-react = import ./nixos-modules/scopone-client-react.nix;
    };
}
