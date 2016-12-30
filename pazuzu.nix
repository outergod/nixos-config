{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./audio.nix
      ./virtualization.nix
      ./nixos-development.nix
    ];

  system.stateVersion = "16.09";
  networking.hostName = "pazuzu.in.sodosopa.io";
  services.avahi.hostName = "pazuzu";
  services.avahi.enable = false;
  
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.driSupport32Bit = true;

  services.printing = {
    enable = true;
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

  ipa = {
    enable = true;
    domain = "in.sodosopa.io";
    realm  = "IN.SODOSOPA.IO";
    server = "ipa.in.sodosopa.io";
    basedn = "dc=in,dc=sodosopa,dc=io";
  };
  
  services.sssd.enable = true;

  networking.extraHosts = "192.168.122.2 ipa.in.sodosopa.io";
}
