# Home Manager configuration for mizutani
{ config, pkgs, ... }:

{
  imports = [
    ./profiles/base.nix
    ./profiles/desktop.nix
    ./profiles/developer.nix
    ./profiles/gaming.nix
    ./modules/firefox.nix
  ];

  home.username = "mizutani";
  home.homeDirectory = "/home/mizutani";
  home.stateVersion = "24.05";

  # Additional packages not in profiles
  home.packages = with pkgs; [
    nicotine-plus
    spotdl
    ani-cli
    tor
    kew
    lidarr
    prowlarr
    qbittorrent
  ];
}
