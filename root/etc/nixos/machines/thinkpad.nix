{ config, pkgs, ... }:

{
  imports = [ 
    ../common.nix
    ./falcon.nix
  ];
  boot.initrd.kernelModules = [ "i915" ];

  hardware.cpu.intel.updateMicrocode = true;
  hardware.ksm.enable = true;
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
    ];
  };
  hardware.video.hidpi.enable = false;

  networking.hostName = "motherbase"; # Define your hostname.

  services.xserver.videoDrivers = [ "modesetting" ];
  services.xserver.useGlamor = true;
  services.xserver.xrandrHeads = [ "DP-3" "eDP-1" ];

  systemd.services.mywarp = {
    enable = true;
    description = "Warp server";
    unitConfig = {
      Type = "simple";
    };
    serviceConfig = {
      ExecStart = "/home/gipsy/.nix-profile/bin/warp-svc";
    };
    wantedBy = [ "multi-user.target" ];
  };

}
