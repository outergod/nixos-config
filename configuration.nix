# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, emacs-overlay, zen-browser, ... }:

{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };

    plymouth = {
      enable = true;
      theme = "deus_ex";
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "deus_ex" ];
        })
      ];
    };

    # Enable "Silent Boot"
    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];

    initrd.systemd.enable = true;

    kernel.sysctl = { "vm.swappiness" = 10; };
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  hardware.pulseaudio.enable = false;

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.outergod = {
    description = "Alexander Dorn";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      firefox
      tree
    ];
  };

  security = {
    sudo.wheelNeedsPassword = false;
    polkit.enable = true;
    pam.services.gdm.enableGnomeKeyring = true;
  };

  nixpkgs = {
    config.allowUnfree = true;

    overlays = [ emacs-overlay.overlays.default ];
  };

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    seahorse.enable = true;

    zsh.enable = true;

    hyprland.enable = true;
    hyprlock.enable = true;

    gamescope = {
      enable = true;
      capSysNice = true;
    };
    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    gnome-disks.enable = true;
  };

  # List services that you want to enable:
  services = {
    xserver.enable = true;

    xserver.displayManager.gdm.enable = true;
    printing.enable = true;
    openssh.enable = true;
    udisks2.enable = true;
    flatpak.enable = true;
    hypridle.enable = true;
    gnome.gnome-keyring.enable = true;
    gvfs.enable = true;
    gnome.sushi.enable = true;

    pipewire = {
      enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
      alsa.enable = true;
    };

    emacs = {
      enable = true;
      defaultEditor = true;
      package = with pkgs; (
        (emacsPackagesFor emacs-pgtk).emacsWithPackages (
          epkgs: [ epkgs.vterm ]
        )
      );
    };

    tor = {
      enable = true;
      client.enable = true;
      settings = {
        UseBridges = true;
        ClientTransportPlugin = "obfs4 exec ${pkgs.obfs4}/bin/lyrebird";
        Bridge = "obfs4 159.253.120.121:443 37AAAA91E8A34BFAEF3E3753C71996371A5F2735 cert=zxrBDwpyFNNMxcFZrkP12PD9PCKMxDsDg3aL7XJMlG+R9bVfafBY4Y07PVmuLHNeODr7cw iat-mode=0";
      };
    };
  };

  networking.firewall.enable = false;

  environment = {
    systemPackages = with pkgs; [
      vim jq chezmoi eza bottom procs ripgrep strace git xh curl fd dex libsecret neofetch pavucontrol unzip bc cargo p7zip file john hashcat
      inxi pciutils lshw hwinfo usbutils udiskie encfs
      nodePackages.prettier imagemagick
      dunst alacritty hyprpaper hyprcursor waybar xwaylandvideobridge libnotify waypaper swww shotwell
      rofi-wayland rofi-bluetooth rofi-calc rofi-power-menu rofi-pulse-select rofi-rbw-wayland rofi-screenshot rofi-systemd rofi-top rofi-vpn rofi-wayland rofimoji
      webcord-vencord bitwarden librewolf
      zen-browser.packages."${system}".specific tor-browser
      synology-drive-client zapzap lutris protonup-qt
      gnome.gnome-font-viewer polkit_gnome gnome.nautilus
      mpv celluloid ffmpegthumbnailer audacity
      unrar
      libheif libheif.out
      activitywatch aw-server-rust aw-qt aw-watcher-afk aw-watcher-window-wayland
      rust-analyzer
    ];
    pathsToLink = [ "share/thumbnailers" ];
    sessionVariables.NIXOS_OZONE_WL = "1";
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    roboto
  ];

  nix.settings = {
    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
    ];

    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    experimental-features = [ "nix-command" "flakes" ];
  };

  system.stateVersion = "24.05"; # Did you read the comment?
}
