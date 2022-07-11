{ config, pkgs, ... }:

{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.consoleMode = "2";
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelParams = [];
  boot.plymouth.enable = true;

  # Use latest kernel
  # boot.kernelPackages will use linuxPackages by default, so no need to define it
  #nixpkgs.config.packageOverrides = in_pkgs :
  #  {
  #    linuxPackages = in_pkgs.linuxPackages_latest;
  #    #vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  #  };

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
