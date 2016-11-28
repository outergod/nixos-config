# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./host.nix
    ];

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  networking.networkmanager.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;

  services.ntp.enable = true;

  services.emacs = {
    enable = true;
    package = pkgs.emacs25;
    defaultEditor = true;
  };

  programs.zsh.enable = true;
  security.sudo.wheelNeedsPassword = false;

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

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts  # Micrsoft free fonts
      inconsolata  # monospaced
      unifont # some international languages
    ];
  };
  
  environment.systemPackages = with pkgs; [
    curl wget git gnumake nodejs-6_x owncloud-client
    chromium mu gnupg isync libsecret pcsctools pass
    yubikey-neo-manager yubikey-personalization-gui yubikey-personalization
    nixui slack nssTools
  ];
}

