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
  services.xserver.videoDrivers = [ "nvidia" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

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
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource NVIDIA-G0 "Unknown AMD Radeon GPU @ pci:0000:06:00.0"
  '';


  services.autorandr = {
    enable = true;
    profiles = {
      "default" = {
        fingerprint = {
          eDP-1 = "00ffffffffffff0009e57409000000001b1e0104a5221378070125a5534ba0270e505400000001010101010101010101010101010101403f00afa0a028503020360058c210000018000000fd0030a5f4f443010a202020202020000000fe00424f452043510a202020202020000000fe004e4531353651484d2d4e59320a01267013790000030114e5040184ff09ae002f001f009f0527000200050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001890";
        };
        config = {
          eDP-1 = {
            enable = true;
            crtc = 0;
            primary = true;
            position = "0x0";
            mode = "2560x1440";
            rate = "165.00";
          };
          HDMI-1-0.enable = false;
        };
      };
      "hdmi" = {
        fingerprint = {
          eDP-1 = "00ffffffffffff0009e57409000000001b1e0104a5221378070125a5534ba0270e505400000001010101010101010101010101010101403f00afa0a028503020360058c210000018000000fd0030a5f4f443010a202020202020000000fe00424f452043510a202020202020000000fe004e4531353651484d2d4e59320a01267013790000030114e5040184ff09ae002f001f009f0527000200050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001890";
          HDMI-1-0 = "*";
        };
        config = {
          eDP-1 = {
            enable = true;
            crtc = 0;
            primary = true;
            position = "0x0";
            mode = "2560x1440";
            rate = "165.00";
          };
          HDMI-1-0 = {
            enable = true;
            primary = false;
            position = "2560x0";
            mode = "1920x1080";
            rate = "60.00";
          };
        };
      };
    };
  };
  # specialisation = {
   # external-display.configuration = {
     # system.nixos.tags = [ "external-display" ];
     # hardware.nvidia.prime.offload.enable = lib.mkForce false;
     # hardware.nvidia.powerManagement.enable = lib.mkForce false;
   # };
  # };
}

