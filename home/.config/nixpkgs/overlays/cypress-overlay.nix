# When Cypress starts, it copies some files into `~/.config/Cypress/cy/production/browsers/chrome-stable/interactive/CypressExtension/`
# from the Nix Store, one of which it attempts to modify immediately after.
# As-is, this fails because the copied file keeps the read-only flag it had in
# the Store.
# Luckily, the code responsible is a plain text script that we can easily patch:
final: prev: {
  cypress = prev.cypress.overrideAttrs (oldAttrs: {
    installPhase = let
      old = "copyExtension(pathToExtension, extensionDest)";
      # This has only been tested against Cypress 6.0.0!
      newForChrome =
        "copyExtension(pathToExtension, extensionDest).then(() => fs_1.default.chmodAsync(extensionBg, 0o0644))";
      newForFirefox =
        "copyExtension(pathToExtension, extensionDest).then(() => fs.chmodAsync(extensionBg, 0o0644))";
    in ''
      sed -i 's/${old}/${newForChrome}/' \
          ./resources/app/packages/server/lib/browsers/chrome.js
      sed -i 's/${old}/${newForFirefox}/' \
          ./resources/app/packages/server/lib/browsers/utils.js
    '' + oldAttrs.installPhase;
  });
}
