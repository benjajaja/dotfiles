# Slimbook - AMD/NVIDIA hybrid laptop (hostname: lz)
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
    ./hardware-configuration.nix
  ];

  networking.hostName = "lz";

  hardware = {
    enableAllFirmware = true;
    cpu.amd.updateMicrocode = true;
    graphics.enable = true;
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
}
