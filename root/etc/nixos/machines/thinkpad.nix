{ config, pkgs, lib, fetchurl, ... }:

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

  networking.hostName = "motherbase"; # Define your hostname.

  services.xserver.videoDrivers = [ "modesetting" ];
  services.xserver.xrandrHeads = [ "DP-3" "eDP-1" ];

   environment.systemPackages = with pkgs; [
     cloudflare-warp
     #falcon-sensor
   ];
   systemd.services.cloudflare-warp = {
     enable = true;
     description = "Warp server";
     path = [ pkgs.cloudflare-warp ];
     unitConfig = {
       Type = "simple";
     };
     serviceConfig = {
       ExecStart = "${pkgs.cloudflare-warp}/bin/warp-svc";
     };
     #wantedBy = [ "multi-user.target" ];
   };
  # custom.falcon.enable = true;
}
