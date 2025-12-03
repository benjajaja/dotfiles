# CrowdStrike Falcon Sensor NixOS module
{ config, lib, pkgs, ... }:

{
  options.custom.falcon = {
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
      falcon-sensor = pkgs.callPackage ../packages/falcon-sensor.nix {};

      startPreScript = pkgs.writeScript "init-falcon" ''
        #!${pkgs.bash}/bin/sh
        /run/current-system/sw/bin/mkdir -p /opt/CrowdStrike
        /run/current-system/sw/bin/touch /var/log/falconctl.log
        ln -sf ${falcon-sensor}/opt/CrowdStrike/* /opt/CrowdStrike
        ${falcon-sensor}/opt/CrowdStrike/falconctl -s -f --cid="693253C8D7A64D31BEE515660EB89FAE-1E"
        ${falcon-sensor}/bin/fs-bash -c "${falcon-sensor}/opt/CrowdStrike/falconctl -g --cid"
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
          ExecStart = "${falcon-sensor}/bin/fs-bash -c \"${falcon-sensor}/opt/CrowdStrike/falcond\"";
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
