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
        sha256 = "7fcddbac8868c45bf457118cb2d25e2ceb0aeea2ab0662ebfcdb6c07d9bb2241";
        url = "https://github.com/getferdi/ferdi/releases/download/v5.8.0/Ferdi-5.8.0-arm64.dmg";
      };
    } else { };

  apps = builtins.listToAttrs (builtins.map (c: { name = c.token; value = c; }) validCasks);
in
lib.attrsets.mapAttrs
  (name: value: caskApp {
    cask = value // (if builtins.hasAttr name armOverrides then armOverrides.${name} else { });
  })
  apps
