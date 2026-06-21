# Developer home profile - development tools
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    code-cursor
    lazygit
    jdk
    python3
    godot
    claude-code
    filezilla
  ];
}
