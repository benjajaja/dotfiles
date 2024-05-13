with import <nixpkgs> {};
with pkgs;


self: super: {

    cloudflare-warp = super.cloudflare-warp.overrideAttrs (oldAttrs: rec {
        version = "2022.9.591";

        src = super.fetchurl {
          url = "https://pkg.cloudflareclient.com/uploads/cloudflare_warp_2022_9_591_1_amd64_3e650240f8.deb";
          sha256 = "sha256-tZ4yMyg/NwQYZyQ+zALHzpOEmD/SL7Xmav77KED6NHU=";
        };
    });

}
