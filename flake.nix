{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
  };

  outputs = { self, nixpkgs, nix-minecraft }@inputs: {
    nixosConfigurations = {
      blackwall = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/blackwall ];
      };

      # Future hosts (laptop, desktop) will be added here:
      # elysia = nixpkgs.lib.nixosSystem { ... };
      # canto = nixpkgs.lib.nixosSystem { ... };
    };
  };
}
