{ config, pkgs, lib, ... }:

{
  imports = [ 
    ../common.nix
  ];
  networking.hostName = "lz"; # Define your hostname.

  # services.xserver.xrandrHeads = [ "eDP-1" ];
  # boot.kernelPackages = "
  services.xserver.videoDrivers = [ "nvidia" "amdgpu" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

  hardware = {
    enableAllFirmware = true;
    cpu.amd.updateMicrocode = true;
    opengl.enable = true;
    opengl.driSupport = true;
    opengl.driSupport32Bit = true;
  };

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      sync.enable = false;
      offload.enable = false;
      nvidiaBusId = "PCI:1:0:0";
      amdgpuBusId = "PCI:6:0:0";
    };
    powerManagement = {
      enable = false;
      finegrained = false;
    };
    modesetting.enable = true;
    nvidiaPersistenced = true;
  };

  # hardware.nvidia.modesetting.enable = true;

  #specialisation = {
  #  external-display.configuration = {
  #    system.nixos.tags = [ "external-display" ];
  #    hardware.nvidia.prime.offload.enable = lib.mkForce false;
  #    hardware.nvidia.powerManagement.enable = lib.mkForce false;
  #  };
  #};
}

