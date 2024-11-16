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

  hardware = {
    pulseaudio.enable = false;

    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        rocmPackages.clr.icd
      ];
    };

    keyboard.qmk.enable = true;
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
      capSysNice = false;
    };
    gamemode = {
      enable = true;
      enableRenice = true;
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
        Bridge = "obfs4 78.199.154.217:34161 29C8E90E8FEBB7F5F67C4364224FBF4747DFA0A6 cert=xjmoErJgpqn0jDBVsnjCm29/KDuQ4HBqulQpxRYqDBswI66i3YEDH/Zk8hk6Kw4yOP3cPQ iat-mode=0";
      };
    };

    avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        hinfo = true;
        userServices = true;
        workstation = true;
      };
      extraServiceFiles = {
        smb = ''
          <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
          <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
          <service-group>
            <name replace-wildcards="yes">%h</name>
            <service>
              <type>_smb._tcp</type>
              <port>445</port>
            </service>
          </service-group>
        '';
      };
    };

    samba = {
      enable = true;

      # You will still need to set up the user accounts to begin with:
      # $ sudo smbpasswd -a yourusername

      # This adds to the [global] section:
      extraConfig = ''
        browseable = yes
        smb encrypt = required
      '';

      shares = {
        homes = {
          browseable = "yes";  # note: each home will be browseable; the "homes" share will not.
          "read only" = "no";
          "guest ok" = "no";
        };
      };
    };
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
    wlr.enable = true;
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 445 139 22 ];
    allowedUDPPorts = [ 137 138 ];
  };

  environment = {
    systemPackages = with pkgs; [
      vim jq chezmoi eza bottom procs ripgrep strace git xh curl fd dex libsecret neofetch pavucontrol unzip bc cargo p7zip file john hashcat
      inxi pciutils lshw hwinfo usbutils udiskie encfs
      nodePackages.prettier imagemagick
      dunst alacritty hyprpaper hyprcursor waybar xwaylandvideobridge libnotify waypaper swww shotwell
      rofi-wayland rofi-bluetooth rofi-calc rofi-power-menu rofi-pulse-select rofi-rbw-wayland rofi-screenshot rofi-systemd rofi-top rofi-vpn rofi-wayland rofimoji
      webcord-vencord bitwarden librewolf
      zen-browser.packages."${system}".specific tor-browser
      synology-drive-client zapzap lutris dosbox protonplus
      gnome.gnome-font-viewer polkit_gnome gnome.nautilus
      mpv celluloid ffmpegthumbnailer audacity picard
      unrar insync
      libheif libheif.out
      activitywatch aw-server-rust aw-qt aw-watcher-afk aw-watcher-window-wayland
      rust-analyzer
      inkscape
      cifs-utils dig
      qmk
      (pkgs.wrapOBS {
        plugins = with obs-studio-plugins; [
          wlrobs obs-vkcapture input-overlay
        ];
      })
      (haskellPackages.ghcWithPackages (pkgs: with pkgs; [ cabal-install ]))
    ];
    pathsToLink = [ "share/thumbnailers" ];
    sessionVariables.NIXOS_OZONE_WL = "1";
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    (nerdfonts.override { fonts = [ "FiraCode" "Noto" "NerdFontsSymbolsOnly" ]; })
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
