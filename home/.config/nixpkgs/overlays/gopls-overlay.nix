self: super: {
  gopls = super.callPackage "${super.path}/pkgs/development/tools/language-servers/gopls" {
    buildGoModule = args: super.buildGoModule (args // rec {
      version = "0.12.4";

      src = super.fetchFromGitHub {
        owner = "golang";
        repo = "tools";
        rev = "gopls/v${version}";
        sha256 = "sha256-OieIbWgc5l7HS6otkRxsKYQmNIjPbADQ+C3A6qJr2h0=";
      };
      vendorSha256 = "sha256-0Svz0VFmNW/f8Po+DpIQi0bJB1ICLcSJM1sG/Nju+ZY=";
    });
  };
}

