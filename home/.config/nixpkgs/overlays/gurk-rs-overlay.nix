with import <nixpkgs> {};
with pkgs;

self: super: {
  gurk-rs = super.gurk-rs.overrideAttrs (oldAttrs: rec {
    name = "gurk-rs-${version}";
    version = "0.3.0";
    src = super.fetchFromGitHub {
      owner = "boxdot";
      repo = oldAttrs.pname;
      rev = "v0.3.0";
      sha256 = "sha256-uJvi082HkWW9y8jwHTvzuzBAi7uVtjq/4U0bO0EWdVM=";
    };
    # cargoHash = lib.fakeHash;
    cargoDeps = oldAttrs.cargoDeps.overrideAttrs (lib.const {
      name = "${name}-vendor.tar.gz";
      inherit src;
      outputHash = lib.fakeHash;
    });
  });
}

