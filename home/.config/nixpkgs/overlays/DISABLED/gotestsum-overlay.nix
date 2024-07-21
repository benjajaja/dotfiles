with import <nixpkgs> {};
with pkgs;

self: super: {
  gotestsum = super.callPackage "${super.path}/pkgs/development/tools/gotestsum" {
    buildGoModule = args: super.buildGoModule (args // rec {
      version = "1.12.0";
      go = pkgs.go_1_22;

      src = super.fetchFromGitHub {
        owner = "gotestyourself";
        repo = "gotestsum";
        # rev = "v${version}";
        rev = "refs/tags/v${version}";
        sha256 = "sha256-eve3G5JhvaUapAenoIDn2ClHqljpviVpmJl4ZaAUqTs=";
      };
      ldflags = [
        "-s"
        "-w"
        "-X gotest.tools/gotestsum/cmd.version=${version}"
      ];
      vendorHash = "sha256-7E2HEPAuZeHyNq7YWoSVDvv/oOFdgSh4mcRZVvfu/+0=";
    });
  };
}


