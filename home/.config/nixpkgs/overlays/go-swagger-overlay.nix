with import <nixpkgs> {};
with pkgs;

self: super: {
  go-swagger = super.go-swagger.overrideAttrs (old: let
    version = "0.30.2";
    src = super.fetchFromGitHub {
      owner = "go-swagger";
      repo = old.pname;
      rev = "v${version}";
      sha256 = "sha256-RV+oXcu74lyc3v3i3aQvKqrm6KrKwvPwED4JAwXgjqw=";
    };
    in rec {
      name = "go-swagger-x-${version}";
      inherit src version;
      go-modules = (pkgs.buildGoModule {
        inherit name src;
        vendorSha256 = "sha256-F20/EQjlrwYzejLPcnuzb7K9RmbbrqU+MwzBO1MvhL4=";
      }).go-modules;
    }
  );
}

    # let
      # version = "0.30.2";
      # src = pkgs.fetchFromGitHub {
        # owner = "go-swagger";
        # repo = "go-swagger";
        # rev = "v${version}";
        # sha256 = "sha256-RV+oXcu74lyc3v3i3aQvKqrm6KrKwvPwED4JAwXgjqw=";
      # };
    # in
    # (pkgs.go-swagger.override rec {
      # buildGoModule = args: pkgs.buildGoModule.override { go = pkgs.go_1_17; } (args // {
        # inherit src version;
        # vendorSha256 = "sha256-HJLT0CGUVzJZ56vS/v3FZ7svxyzZ+wlXvrC2MExTLM4=";
      # });
    # });
