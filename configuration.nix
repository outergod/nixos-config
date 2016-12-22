# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  emacsclient = pkgs.writeTextFile {
    name = "emacsclient";
    text = ''
      [Desktop Entry]
      Name=Emacs Client
      GenericName=Text Editor
      Comment=Edit text
      MimeType=text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;
      Exec=emacseditor %F
      Icon=emacs
      Type=Application
      Terminal=false
      Categories=Development;TextEditor;
      StartupWMClass=Emacs
      Keywords=Text;Editor;
    '';
    destination = "/share/applications/emacsclient.desktop";
  };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./host.nix
    ];

  boot.plymouth.enable = true;
  
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  networking.networkmanager.enable = true;

  # List services that you want to enable:

  services.dbus = {
    enable = true;
    socketActivated = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  programs.ssh.package = pkgs.openssh_with_kerberos;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;

  services.ntp.enable = true;

  services.emacs = {
    enable = true;
    package = pkgs.emacs25.override {
      withGTK3 = true;
      withGTK2 = false;
    };
    defaultEditor = true;
  };

  services.avahi = {
    nssmdns = true;
    publish.enable = true;
    publish.addresses = true;
    publish.workstation = true;
  };

  programs.zsh.enable = true;
  security.sudo.wheelNeedsPassword = false;
  security.pam.makeHomeDir = true;

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

    packageOverrides = pkgs: {
      msmtp = pkgs.lib.overrideDerivation pkgs.msmtp (attrs: {
        nativeBuildInputs = attrs.nativeBuildInputs ++ [ pkgs.libsecret pkgs.glib ];
        configureFlags = attrs.configureFlags ++ [
          "--with-libsecret"
        ];
      });
    };
  };    

  services.pcscd.enable = true;

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fontconfig.hinting.style = "slight";
    fonts = with pkgs; [
      corefonts  # Micrsoft free fonts
      inconsolata  # monospaced
      unifont # some international languages
    ];
  };

  systemd.user.services.gnome-terminal-server = {
    description = "GNOME Terminal Server";

    serviceConfig = {
      KillMode = "process";
      Type = "dbus";
      BusName = "org.gnome.Terminal";
      ExecStart = "${pkgs.gnome3.gnome_terminal}/libexec/gnome-terminal-server";
    };
    environment = { DISPLAY = ":${toString config.services.xserver.display}"; };
    restartIfChanged = true;
  };

  environment.systemPackages = with pkgs; [
    emacsclient wmctrl curl wget git gnumake nodejs-6_x owncloud-client
    chromium mu gnupg isync msmtp libsecret pcsctools pass
    yubikey-neo-manager yubikey-personalization-gui yubikey-personalization
    nixui nix-repl nox
    slack nssTools
    gnome3.gnome-disk-utility parted
    libreoffice openjdk gimp
    man-pages
    ec2_api_tools
    (texlive.combine {
      inherit (texlive) scheme-small xetex textpos isodate substr titlesec;
    })
  ];
}
