# Productivity tools
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    obsidian
    libreoffice
    zotero
    jdk
    nicotine-plus
    spotdl
    ani-cli
    filezilla
    tor
    tor-browser
    protonvpn-gui
    code-cursor
    google-chrome
    jellyfin
    python3
    godot
    claude-code
    lazygit
  ];
}
