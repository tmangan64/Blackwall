# Gaming home profile
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    steam
    prismlauncher
    piper
    libratbag
    adwsteamgtk
  ];
}
