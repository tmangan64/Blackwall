# Automatic system upgrades
{ config, ... }:

{
  system.autoUpgrade = {
    enable = true;
    flake = "github:tmangan64/Blackwall#blackwall";
    flags = [
      "--update-input" "nixpkgs"
      "--no-write-lock-file"
    ];
    dates = "04:00";
    randomizedDelaySec = "45min";
    allowReboot = true;
  };

  boot.loader.systemd-boot.configurationLimit = 10;
}
