# Home Manager configuration for mizutani
{ config, pkgs, inputs, ... }:

{
  imports = [
    ./terminal.nix
    ./productivity.nix
    ./gaming.nix
  ];

  home.username = "mizutani";
  home.homeDirectory = "/home/mizutani";
  home.stateVersion = "24.05";

  nixpkgs.config.allowUnfree = true;
}
