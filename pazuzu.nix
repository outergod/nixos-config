{ config, pkgs, ... }:

{
  imports =
    [
      ./audio.nix
    ];

  system.stateVersion = "16.09";
  networking.hostName = "pazuzu.in.sodosopa.io";
  services.avahi.hostName = "pazuzu";
  
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.driSupport32Bit = true;

  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ];
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 18171 ];
    allowedUDPPorts = [ 18171 ];
    allowPing = true;
  };

  environment.systemPackages = with pkgs; [
    encfs steam
  ];
}
