# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./host.nix
      ./audio.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;

  programs.zsh.enable = true;

  users.extraUsers.akahl = {
    isNormalUser = true;
    uid = 1000;
    description = "Alexander Kahl";
    extraGroups = [ "wheel" "audio" ];
    shell = "/run/current-system/sw/bin/zsh";
  };

  nixpkgs.config = {
    allowUnfree = true;

    chromium = {
      enablePepperFlash = true;
      enablePepperPDF = true;
    };
  };    

  services.pcscd.enable = true;
  
  environment.systemPackages = with pkgs; [
    chromium inconsolata mu gnupg isync libsecret pcsctools
    yubikey-neo-manager yubikey-personalization-gui yubikey-personalization
    nixui encfs
    slack
  ];

  services.emacs = {
    enable = true;
    package = pkgs.emacs25;
    defaultEditor = true;    
  };
  
  security.sudo.wheelNeedsPassword = false;
}

