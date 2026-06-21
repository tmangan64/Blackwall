# Desktop home profile - productivity and desktop apps
{ pkgs, ... }:

let
  obsidian-adwaita-theme = pkgs.fetchFromGitHub {
    owner = "birneee";
    repo = "obsidian-adwaita-theme";
    rev = "main";
    sha256 = "0cri1f2w36g9qk54sjsir2hfyydwj9j5if1zqk3ifljcydyc4y5j";
  };
in
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

  # Obsidian Adwaita theme
  home.file."Documents/Vaults/BlackwallVault/.obsidian/themes/Adwaita/theme.css".source = "${obsidian-adwaita-theme}/theme.css";
  home.file."Documents/Vaults/BlackwallVault/.obsidian/themes/Adwaita/manifest.json".source = "${obsidian-adwaita-theme}/manifest.json";
  home.file."Documents/Vaults/BlackwallVault/.obsidian/appearance.json".text = ''
    {
      "cssTheme": "Adwaita"
    }
  '';
}
