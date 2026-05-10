{
  description = "Blackwall - Dendritic NixOS multi-host configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    curd = {
      url = "github:Wraient/curd";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, disko, sops-nix, curd, ... }@inputs:
  let
    system = "x86_64-linux";

    # Shared specialArgs for all hosts
    mkSpecialArgs = hostname: {
      inherit inputs self;
      hostname = hostname;
    };

    # Override nextcloud33 to version 33.0.3 to prevent downgrade error
    nextcloudOverlay = final: prev: {
      nextcloud33 = prev.nextcloud33.overrideAttrs (old: rec {
        version = "33.0.3";
        src = prev.fetchurl {
          url = "https://download.nextcloud.com/server/releases/nextcloud-${version}.tar.bz2";
          sha256 = "sha256-XBBS+GCzWqVrJLwmE6a+oMIjE7n70CuwJHwfC52/d9I=";
        };
      });
    };
  in
  {
    nixosConfigurations = {

      # Desktop - Gaming and development workstation
      elysia = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = mkSpecialArgs "elysia";
        modules = [
          ./hosts/elysia
          home-manager.nixosModules.home-manager
        ];
      };

      # Laptop - Thinkpad X1 Carbon for development
      canto = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = mkSpecialArgs "canto";
        modules = [
          ./hosts/canto
          home-manager.nixosModules.home-manager
        ];
      };

      # Server - Beelink homeserver
      blackwall = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = mkSpecialArgs "blackwall";
        modules = [
          { nixpkgs.overlays = [ nextcloudOverlay ]; }
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
          ./hosts/blackwall
        ];
      };

    };
  };
}
