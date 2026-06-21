{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

  outputs = { self, nixpkgs }: {
    nixosConfigurations = {
      blackwall = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/blackwall ];
      };

      # Future hosts (laptop, desktop) will be added here:
      # elysia = nixpkgs.lib.nixosSystem { ... };
      # canto = nixpkgs.lib.nixosSystem { ... };
    };
  };
}
