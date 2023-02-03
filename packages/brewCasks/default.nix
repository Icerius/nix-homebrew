{
  lib,
  pkgs,
}: let
  caskApp = pkgs.callPackage ./caskApp.nix;
  casks = lib.importJSON ./cask.json;
  # Some apps do not contain a valid sha256 hash
  validCasks = builtins.filter (e: e.sha256 != "no_check") casks;

  # Current JSON only contains x86 variants, quickfix to support arm
  armOverrides =
    if pkgs.system == "aarch64-darwin"
    then {
      ferdium = {
        sha256 = "555380ed0ff989555c0c08eafefdafbb60a7e227b3a432380c8a0eed75195808";
        url = "https://github.com/ferdium/ferdium-app/releases/download/v6.2.4/Ferdium-mac-6.2.4-arm64.dmg";
      };
      jetbrains-toolbox = {
        sha256 = "051cced2b1e84cc1577c4000308d95726e0ed6725dc81df87b9f33837544d21e";
        url = "https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.27.2.13801-arm64.dmg";
      };
    }
    else {};

  apps = builtins.listToAttrs (builtins.map (c: {
      name = c.token;
      value = c;
    })
    validCasks);
in
  lib.attrsets.mapAttrs
  (name: value:
    caskApp {
      cask =
        value
        // (
          if builtins.hasAttr name armOverrides
          then armOverrides.${name}
          else {}
        );
    })
  apps
