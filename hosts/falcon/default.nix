# Falcon - Desktop (hostname: falcon)
{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "falcon";

  # Add desktop-specific configuration here
  boot.initrd.kernelModules = [ "i915" ];

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  hardware.graphics.enable = true;
}
