{ config, pkgs, ... }:

{
  networking.hostName = "pazuzu.in.sodosopa.io";
  
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.driSupport32Bit = true;

  system.stateVersion = "16.09";

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 18171 ];
    allowedUDPPorts = [ 18171 ];
    allowPing = true;
  };
}
