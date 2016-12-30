{ config, pkgs, ... }:

{
  virtualisation.libvirtd = {
    enable = true;
    enableKVM = true;
  };

  users.extraUsers.akahl.extraGroups = [ "libvirtd" ];

  environment.systemPackages = with pkgs; [
    virtmanager
  ];
}
