{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    playit-nixos-module.url = "github:pedorich-n/playit-nixos-module";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Inputs are reached through specialArgs rather than destructured here, so
  # adding an input is a one-line change above.
  outputs = { self, nixpkgs, ... }@inputs: {
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
