# ThinkPad - Intel laptop (hostname: motherbase)
{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/falcon-sensor.nix
  ];

  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelModules = [];

  hardware.cpu.intel.updateMicrocode = true;
  hardware.ksm.enable = true;
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
    ];
  };

  networking.hostName = "motherbase";

  environment.systemPackages = with pkgs; [
    cloudflare-warp
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
  };
}
