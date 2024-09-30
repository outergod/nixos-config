{ config, lib, pkgs, ... }:

{
  networking = {
    hostName = "phoenix";
    networkmanager.enable = true;
  };
}
