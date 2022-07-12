{ config, pkgs, ... }:

{

  hardware.cpu.intel.updateMicrocode = true;
  hardware.ksm.enable = true;
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      #vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      #vaapiVdpau
      #libvdpau-va-gl
    ];
  };
  hardware.video.hidpi.enable = false;
}
