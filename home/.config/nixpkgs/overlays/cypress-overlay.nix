# When Cypress starts, it copies some files into `~/.config/Cypress/cy/production/browsers/chrome-stable/interactive/CypressExtension/`
# from the Nix Store, one of which it attempts to modify immediately after.
# As-is, this fails because the copied file keeps the read-only flag it had in
# the Store.
# Luckily, the code responsible is a plain text script that we can easily patch:
final: prev: {
  cypress = prev.cypress.overrideAttrs (oldAttrs: rec {
    pname = "cypress";
    version = "10.9.0";

    src = prev.fetchzip {
      url = "https://cdn.cypress.io/desktop/${version}/linux-x64/cypress.zip";
      sha256 = "sha256-aLz7UnQjP3j4B9wk4jPk1g/lzrPQX4eesV0rm+vWBcM=";
    };

    installPhase =
      let
        matchForChrome = "yield utils_1.default.copyExtension(pathToExtension, extensionDest);";
        appendForChrome = "yield fs_1.fs.chmodAsync(extensionBg, 0o0644);";

        matchForFirefox = "copyExtension(pathToExtension, extensionDest)";
        replaceForFirefox = "copyExtension(pathToExtension, extensionDest).then(() => fs.chmodAsync(extensionBg, 0o0644))";
      in
      ''
        sed -i '/${matchForChrome}/a\${appendForChrome}' \
            ./resources/app/packages/server/lib/browsers/chrome.js

        sed -i 's/${matchForFirefox}/${replaceForFirefox}/' \
            ./resources/app/packages/server/lib/browsers/utils.js
      '' + oldAttrs.installPhase;

    shellHook = ''
      export CYPRESS_INSTALL_BINARY=0
      export CYPRESS_RUN_BINARY=${prev.cypress}/bin/Cypress
    '';
  });
}
