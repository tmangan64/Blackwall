# Gaming profile - Steam and gaming tools
{ config, pkgs, ... }:

{
  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    prismlauncher
  ];
}
