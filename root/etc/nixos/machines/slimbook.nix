{ config, pkgs, lib, ... }:

let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in
{
  imports = [ 
    ../common.nix
  ];
  networking.hostName = "lz"; # Define your hostname.

  # services.xserver.xrandrHeads = [ "eDP-1" ];
  # boot.kernelPackages = "
  # services.xserver.videoDrivers = [ "nvidia" ];
  # boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

  hardware = {
    enableAllFirmware = true;
    cpu.amd.updateMicrocode = true;
    opengl.enable = true;
    opengl.driSupport = true;
    opengl.driSupport32Bit = true;
  };

  environment.systemPackages = [ nvidia-offload ];

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      sync.enable = false;
      offload.enable = true;
      nvidiaBusId = "PCI:1:0:0";
      amdgpuBusId = "PCI:6:0:0";
    };
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    modesetting.enable = true;
    # ensure the kernel doesn't tear down the card/driver prior to X startup due to the card powering down.
    nvidiaPersistenced = false; # disable for wayland
  };
  # now set up reverse PRIME by configuring the NVIDIA provider's outputs as a source for the 
  # amdgpu. you'll need to get these providers from `xrandr --listproviders` AFTER switching to the 
  # above config AND rebooting.

  # specialisation = {
   # external-display.configuration = {
     # system.nixos.tags = [ "external-display" ];
     # hardware.nvidia.prime.offload.enable = lib.mkForce false;
     # hardware.nvidia.powerManagement.enable = lib.mkForce false;
   # };
  # };

}

