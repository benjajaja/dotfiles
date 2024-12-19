{ config, pkgs, lib, fetchurl, ... }:

let
  r8152-kernel-module = pkgs.callPackage ./r8152.nix {
    # Make sure the module targets the same kernel as your system is using.
    kernel = config.boot.kernelPackages.kernel;
  };
in
{
  imports = [ 
    ../common.nix
    ./falcon.nix
  ];
  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelModules = [];
  boot.extraModulePackages = [
    (r8152-kernel-module.overrideAttrs (_: {
      patches = [ ./r8152.patch ];
    }))
  ];

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
  environment.etc."kanshi/thinkpad".text = ''
    profile mobile {
            output eDP-1 enable scale 1 mode 1920x1200
    }

    profile docked {
            output eDP-1 disable
            output DP-2 mode 2560x1440@144Hz scale 1.5
    }

    profile docked-open {
            output eDP-1 enable scale 1 mode 1920x1200
            output DP-2 mode 2560x1440@144Hz scale 1.5
    }
    '';
  # kanshi systemd service
  systemd.user.services.kanshi = {
    description = "kanshi daemon";
    serviceConfig = {
      Type = "simple";
      ExecStart = ''${pkgs.kanshi}/bin/kanshi -c /etc/kanshi/thinkpad'';
    };
  };
}
