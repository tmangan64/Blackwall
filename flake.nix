{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    playit-nixos-module.url = "github:pedorich-n/playit-nixos-module";
    # Pinned to the last commit before sops-nix required Go >= 1.26 (bumped
    # 2026-09-17, "Bump go to stable"). sops.package defaults to building
    # sops-install-secrets from *this* system's nixpkgs, so the Go toolchain
    # comes from nixos-25.11, which ships 1.25.10 - master fails to build with
    # "go.mod requires go >= 1.26.0". Following sops-nix's own nixpkgs does not
    # help for the same reason. Unpin once nixpkgs has Go >= 1.26.
    sops-nix = {
      url = "github:Mic92/sops-nix/13616fff713a9f94055c66f15687ebdc17a335df";
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
