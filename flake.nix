{
  description = "Blackwall - Dendritic NixOS multi-host configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, home-manager, nur, ... }@inputs:
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
          { nixpkgs.overlays = [ nur.overlays.default ]; }
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
          { nixpkgs.overlays = [ nur.overlays.default ]; }
        ];
      };

    };
  };
}
