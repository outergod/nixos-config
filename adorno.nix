{ config, pkgs, ... }:

{
  system.stateVersion = "16.09";
  networking.hostName = "adorno.in.lshift.de";
  services.avahi.hostName = "adorno";
  services.avahi.enable = true;
  
  boot.initrd.postMountCommands = ''
    cryptsetup luksOpen --key-file /mnt-root/root/keyfile /dev/sdb2 swap
    swapon /dev/mapper/swap
  '';

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  hardware = {
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
    };
    opengl.driSupport32Bit = true;
    pulseaudio.support32Bit = true;
    bluetooth.enable = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ];
  };

  virtualisation.docker.enable = true;
  users.extraUsers.akahl.extraGroups = ["docker"];

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

  services.jenkinsSlave.enable = true;

  security.pki.certificates = [
    ''
-----BEGIN CERTIFICATE-----
MIIDjjCCAnagAwIBAgIBATANBgkqhkiG9w0BAQsFADA3MRUwEwYDVQQKDAxJTi5M
U0hJRlQuREUxHjAcBgNVBAMMFUNlcnRpZmljYXRlIEF1dGhvcml0eTAeFw0xNjA1
MjYxNjE0MzNaFw0zNjA1MjYxNjE0MzNaMDcxFTATBgNVBAoMDElOLkxTSElGVC5E
RTEeMBwGA1UEAwwVQ2VydGlmaWNhdGUgQXV0aG9yaXR5MIIBIjANBgkqhkiG9w0B
AQEFAAOCAQ8AMIIBCgKCAQEApj9lj4hjVEC8sJRHp9Kl/hTDWjSlT3tIm3fLUf1x
C4x3Ts3eBZBrjfbyM21uaz4gRa+VvI3EEjflfiuC52CdKnTvEmZ4btIiJk1YAD90
N7/QSkzBJIrHlz4ikePC0v0s27zTWlBc/wPn1lUBU1KyX6ZPH3EN5jbFe/S6vxhj
/rcVeLvtnl11TDGihgCiXjEkfJ54nXQYnn/jBeJsgfiOodFv1Iwchd70RwYA5L06
NPInVqNoXcYmOtDItzocRIinWcfUbtBp+tbKN29DK/KYE8HY+NBKySTHfYp9wO3S
kdOc+AdtwU9RRl0zfS/WAS3r3h+rRXG3AstETjkkziPp0wIDAQABo4GkMIGhMB8G
A1UdIwQYMBaAFP+66OU74EaZR4XO2ArUppQbix9DMA8GA1UdEwEB/wQFMAMBAf8w
DgYDVR0PAQH/BAQDAgHGMB0GA1UdDgQWBBT/uujlO+BGmUeFztgK1KaUG4sfQzA+
BggrBgEFBQcBAQQyMDAwLgYIKwYBBQUHMAGGImh0dHA6Ly9pcGEuaW4ubHNoaWZ0
LmRlOjgwL2NhL29jc3AwDQYJKoZIhvcNAQELBQADggEBADg/iuuo7RbZAR/P7lLI
3f6jfXy+DBKO5K6FItFc0fF7FDy2ciLN2xIGR8GHdPkxZ3k4VHHmQKChvs5H3KCM
iqoU5Lk2dk8xYp7R1GW9rgizX3QsFlzqnM2fUnPzOZPNksNPY0Y2QtJ7I0o0qTYa
rC7ZFD9XFtW/EouTqjDhUUkhGIWdsxPM3rr861du4m3w5v9KgFG5j9xCn2jHxC4i
RXVyM9brWPefS2wod5uz02tAEacyZ38gkTtLd6oJGk9a7MregnrGven367NP6b4X
DOjqcyW4QOEQT6DRH4qlnB3c4LaOgvAuRiE98EzMa2qyVFSGGCG6YeaEFb/2+ZHj
lP0=
-----END CERTIFICATE-----
    ''
  ];

  nixpkgs.config.packageOverrides = pkgs: {
    bind = pkgs.lib.overrideDerivation pkgs.bind (attrs: {
      buildInputs = attrs.buildInputs ++ [ pkgs.libkrb5 ];
      configureFlags = attrs.configureFlags ++ [
        "--with-gssapi=${pkgs.libkrb5}"
      ];
    });
  };

  environment.systemPackages = with pkgs; [
    steam openssh_with_kerberos awscli bind
  ];  
}
