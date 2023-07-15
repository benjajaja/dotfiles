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

    # TODO: remove when this gets merged:
  # https://github.com/NixOS/nixpkgs/blob/ba0e1d31f9c28342c0eb9007e5609e56ed76697d/nixos/modules/services/networking/cloudflare-warp.nix
  # nixpkgs.overlays = [
    # (self: super: {
      # cloudflare-warp = super.cloudflare-warp.overrideAttrs (oldAttrs: rec {
          # version = "2022.9.591";
#
          # src = super.fetchurl {
            # url = "https://pkg.cloudflareclient.com/uploads/cloudflare_warp_2022_9_591_1_amd64_3e650240f8.deb";
            # sha256 = "sha256-tZ4yMyg/NwQYZyQ+zALHzpOEmD/SL7Xmav77KED6NHU=";
          # };
      # });
      # falcon-sensor = super.callPackage ../overlays/falcon-sensor.nix { };
    # })
  # ];
  # environment.systemPackages = with pkgs; [
    # cloudflare-warp
    # falcon-sensor
  # ];
  # systemd.services.somemywarp = {
    # enable = false;
    # description = "Warp server";
    # path = [ pkgs.cloudflare-warp ];
    # unitConfig = {
      # Type = "simple";
    # };
    # serviceConfig = {
      # ExecStart = "${pkgs.cloudflare-warp}/bin/warp-svc";
    # };
    # wantedBy = [ "multi-user.target" ];
  # };
  # custom.falcon.enable = true;
}
