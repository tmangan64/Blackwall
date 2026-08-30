{ config, lib, pkgs, inputs, ... }:

with lib;

let
  cfg = config.blackwall.playit;
in
{
  imports = [
    inputs.playit-nixos-module.nixosModules.default
  ];

  options.blackwall.playit = {
    enable = mkEnableOption "playit.gg tunnel agent for external game server access";

    secretPath = mkOption {
      type = types.path;
      description = ''
        Path to the playit secret file containing the secret_key.
        The file should be a TOML file with the format:
          secret_key = "your-secret-key-here"

        Generate a claim code with:
          nix run github:pedorich-n/playit-nixos-module#playit -- claim generate

        Then exchange it at playit.gg to get your secret key.
      '';
      example = "/run/secrets/playit-secret";
    };
  };

  config = mkIf cfg.enable {
    services.playit = {
      enable = true;
      secretPath = cfg.secretPath;
    };
  };
}
