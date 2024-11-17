{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-intel" "i915" ];
    extraModulePackages = [ ];
    initrd.luks.devices."enc".device = "/dev/disk/by-uuid/b7b3556d-6a96-413d-a408-be0cd664b4a8";

    plymouth = {
      enable = true;
      theme = "bgrt";
    };
  };

  networking = {
    hostName = "phoenix";
    networkmanager.enable = true;
    useDHCP = lib.mkDefault true;
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/af9a7569-8361-42ad-9811-bc6ed160cad3";
      fsType = "btrfs";
      options = [ "subvol=root" "compress=zstd" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/af9a7569-8361-42ad-9811-bc6ed160cad3";
      fsType = "btrfs";
      options = [ "subvol=home" "compress=zstd" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/af9a7569-8361-42ad-9811-bc6ed160cad3";
      fsType = "btrfs";
      options = [ "subvol=nix" "compress=zstd" "noatime" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/C1D9-5DB2";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/6705a427-fff5-47bb-8e20-d3e4dbd7d9dd"; }
    ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
