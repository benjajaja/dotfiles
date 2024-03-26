self: super: {
  gotestsum = super.callPackage "${super.path}/pkgs/development/tools/gotestsum" {
    buildGoModule = args: super.buildGoModule (args // rec {
      version = "1.10.1";

      src = super.fetchFromGitHub {
        owner = "gotestyourself";
        repo = "gotestsum";
        # rev = "v${version}";
        rev = "refs/tags/v${version}";
        sha256 = "sha256-Sq0ejnX7AJoPf3deBge8PMOq1NlMbw+Ljn145C5MQ+s=";
      };
      ldflags = [
        "-s"
        "-w"
        "-X gotest.tools/gotestsum/cmd.version=${version}"
      ];
      vendorHash = "sha256-zUqa6xlDV12ZV4N6+EZ7fLPsL8U+GB7boQ0qG9egvm0=";
    });
  };
}


