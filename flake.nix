{
  description = "Scopone card game server";

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
        defaultPackage = self.packages.${system}.scopone-server;
      }
    ) // {
      nixosModules.scopone-server = import ./nixos-modules/scopone-server.nix;
    };
}
