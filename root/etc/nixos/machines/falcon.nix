{ config, lib, pkgs, ... }:

# Copied from: https://gist.github.com/spinus/be0ca03def0c856ada86b16d1727d09d
# Copied from: https://gitlab.com/JanKaifer/nixos/-/blob/82d9d9d7d7172679d0f476fda0bab20a712b15c8/modules/falcon-sensor/default.nix

{
  options.custom.falcon =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Whether to install Falcon Sensor from CrowdStrike.
        '';
      };
    };

  config =
    let
      startPreScript = pkgs.writeScript "init-falcon" ''
        #!${pkgs.bash}/bin/sh
        /run/current-system/sw/bin/mkdir -p /opt/CrowdStrike
        /run/current-system/sw/bin/touch /var/log/falconctl.log
        ln -sf ${pkgs.falcon-sensor}/opt/CrowdStrike/* /opt/CrowdStrike
        ${pkgs.falcon-sensor}/opt/CrowdStrike/falconctl -s -f --cid="693253C8D7A64D31BEE515660EB89FAE-1E"
        ${pkgs.falcon-sensor}/bin/fs-bash -c "${pkgs.falcon-sensor}/opt/CrowdStrike/falconctl -g --cid"
      '';
    in

    lib.mkIf config.custom.falcon.enable {
      systemd.services.falcon-sensor = {
        enable = false;
        description = "CrowdStrike Falcon Sensor";
        unitConfig.DefaultDependencies = false;
        after = [ "local-fs.target" ];
        conflicts = [ "shutdown.target" ];
        before = [ "sysinit.target" "shutdown.target" ];
        serviceConfig = {
          ExecStartPre = "${startPreScript}";
          ExecStart = "${pkgs.falcon-sensor}/bin/fs-bash -c \"${pkgs.falcon-sensor}/opt/CrowdStrike/falcond\"";
          Type = "forking";
          PIDFile = "/run/falcond.pid";
          Restart = "no";
          TimeoutStopSec = "60s";
          KillMode = "process";
        };
        wantedBy = [ "multi-user.target" ];
      };
    };
}
# {  pkgs, ... }:
# let
  # falcon = pkgs.callPackage ./falcon { };
  # startPreScript = pkgs.writeScript "init-falcon" ''
    #! ${pkgs.bash}/bin/sh
    # /run/current-system/sw/bin/mkdir -p /opt/CrowdStrike
    # ln -sf ${falcon}/opt/CrowdStrike/* /opt/CrowdStrike
    # ${falcon}/bin/fs-bash -c "${falcon}/opt/CrowdStrike/falconctl -s --cid=693253C8D7A64D31BEE515660EB89FAE-1E"
  # '';
# in {
  # systemd.services.falcon-sensor = {
    # enable = true;
    # description = "CrowdStrike Falcon Sensor";
    # unitConfig.DefaultDependencies = false;
    # after = [ "local-fs.target" ];
    # conflicts = [ "shutdown.target" ];
    # before = [ "sysinit.target" "shutdown.target" ];
    # serviceConfig = {
      # ExecStartPre = "${startPreScript}";
      # ExecStart = "${falcon}/bin/fs-bash -c \"${falcon}/opt/CrowdStrike/falcond\"";
      # Type = "forking";
      # PIDFile = "/run/falcond.pid";
      # Restart = "no";
      # TimeoutStopSec = "60s";
      # KillMode = "process";
    # };
    # wantedBy = [ "multi-user.target" ];
  # };
# }
