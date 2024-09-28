{ config, lib, pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking = {
    hostName = "cunderthunt";
    networkmanager.enable = true;
  };
}
