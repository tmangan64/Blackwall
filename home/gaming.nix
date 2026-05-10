# Gaming packages
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    steam
    prismlauncher
    piper
    libratbag
  ];
}
