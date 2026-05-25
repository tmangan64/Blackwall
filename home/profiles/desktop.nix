# Desktop home profile - productivity and desktop apps
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    obsidian
    libreoffice
    zotero
    google-chrome
    tor-browser
    protonvpn-gui
    jellyfin
  ];
}
