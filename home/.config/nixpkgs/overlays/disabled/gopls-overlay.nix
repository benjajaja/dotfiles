with import <nixpkgs> {};
with pkgs;

self: super: {
  gopls = super.gopls.overrideAttrs (old: let
    version = "0.11.0";
    src = super.fetchFromGitHub {
      owner = "golang";
      repo = "tools";
      rev = "gopls/v${version}";
      sha256 = "sha256-49TDAxFx4kSwCn1YGQgMn3xLG3RHCCttMzqUfm4OPtE=";
    };
    name = "gopls-overlay-${version}";
  in rec {
    inherit name version src;
    modRoot = "gopls";
    doCheck = false;
    # Only build gopls, and not the integration tests or documentation generator.
    subPackages = [ "." ];
    vendorSha256 = lib.fakeSha256;
    # go-modules = (pkgs.buildGoModule {
      # inherit name src;
      # vendorSha256 = "sha256-EQHYf4Q+XNjwG/KDoTA4m0mlBGxPkJSLUcO0VHFSpeA=";
    # }).go-modules;
  });
}

