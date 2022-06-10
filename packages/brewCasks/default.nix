{ lib, pkgs }:
let
  caskApp = pkgs.callPackage ./caskApp.nix;
  casks = lib.importJSON ./cask.json;
  # Some apps do not contain a valid sha256 hash
  validCasks = builtins.filter (e: e.sha256 != "no_check") casks;

  # Current JSON only contains x86 variants, quickfix to support arm
  armOverrides =
    if pkgs.system == "aarch64-darwin" then {
      ferdi = {
        sha256 = "ec7ccceba08f1c581290d6ce4f5fa5478bed2c713c592d0298856f7b2719f35d";
        url = "https://github.com/getferdi/ferdi/releases/download/v5.8.1/Ferdi-5.8.1-arm64.dmg";
      };
jetbrains-toolbox = {
sha256 = "bc0564476d767841a85701e2b2a7ee5d28688ee87bb381cc4172612e6938a71a";
url = "https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.24.12080-arm64.dmg";
};

    } else { };

  apps = builtins.listToAttrs (builtins.map (c: { name = c.token; value = c; }) validCasks);
in
lib.attrsets.mapAttrs
  (name: value: caskApp {
    cask = value // (if builtins.hasAttr name armOverrides then armOverrides.${name} else { });
  })
  apps
