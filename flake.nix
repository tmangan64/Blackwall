{
  description = "Blackwall - Dendritic NixOS multi-host configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
  in
  {
    nixosConfigurations = {

      # Desktop - Gaming and development workstation
      elysia = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit inputs self;
          hostname = "elysia";
        };

        modules = [
          ./hosts/elysia
          home-manager.nixosModules.default
        ];
      };

      # Laptop - Thinkpad X1 Carbon for development
      canto = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit inputs self;
          hostname = "canto";
        };

        modules = [
          ./hosts/canto
          home-manager.nixosModules.default
        ];
      };

    };
  };
}
