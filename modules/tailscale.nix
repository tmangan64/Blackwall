{ config, pkgs, lib, ... }:

{
  config = {
    services.tailscale.enable = true;
  };
}
