{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
    initrd.kernelModules = [ "amdgpu"];
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
    initrd.luks.devices."crypted".device = "/dev/disk/by-uuid/40ad8ddb-a4c7-4c26-a0ef-474290d94b12";

    plymouth = {
      enable = true;
      theme = "deus_ex";
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "deus_ex" ];
        })
      ];
    };

  };

  networking = {
    hostName = "cunderthunt";
    networkmanager.enable = true;
    useDHCP = lib.mkDefault true;
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/0618103f-e8a6-46aa-8321-cd40cd62931a";
      fsType = "btrfs";
      options = [ "subvol=root" "compress=zstd" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/0618103f-e8a6-46aa-8321-cd40cd62931a";
      fsType = "btrfs";
      options = [ "subvol=home" "compress=zstd" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/7B9E-CD6C";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0022" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/0618103f-e8a6-46aa-8321-cd40cd62931a";
      fsType = "btrfs";
      options = [ "subvol=nix" "compress=zstd" "noatime" ];
    };

  swapDevices = [ ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  environment = {
    systemPackages = with pkgs; [
      blender-hip
    ];
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu.vhostUserPackages = [ pkgs.virtiofsd ];
  };

  programs.virt-manager.enable = true;

  users.users.outergod.extraGroups = [ "libvirtd" ];
}
