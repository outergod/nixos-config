{ config, pkgs, ... }:

{
  system.stateVersion = "16.09";
  networking.hostName = "adorno.in.lshift.de";

  boot.initrd.postMountCommands = "cryptsetup luksOpen --key-file /mnt-root/root/keyfile /dev/sdb2 swap";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  hardware = {
    pulseaudio.enable = true;
    opengl.driSupport32Bit = true;
    pulseaudio.support32Bit = true;
  };
  
  services.xserver.videoDrivers = [ "nvidia" ];

  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ];
  };

  networking.firewall = {
    enable = false;
    allowPing = true;
  };

  krb5 = {
    enable = true;
    defaultRealm = "IN.LSHIFT.DE";
    domainRealm = "in.lshift.de";
    kdc = "ipa.in.lshift.de";
    kerberosAdminServer = "ipa.in.lshift.de";
  };

  users.extraUsers.sysadmin = {
    isNormalUser = false;
    home = "/home/sysadmin";
    description = "System Maintenance User";
    extraGroups = [ "wheel" ];
  };

  services.ntp.servers = [
    "ipa.in.lshift.de"
  ];

  environment.systemPackages = with pkgs; [
    steam openssh_with_kerberos
  ];  
}
