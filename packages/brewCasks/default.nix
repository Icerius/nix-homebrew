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
        sha256 = "97f9e4f2169c7f2768dea057732713683ed624d8af8d92a4a4ff8f3d9e7227d4";
        url = "https://github.com/ferdium/ferdium-app/releases/download/v6.2.3/Ferdium-mac-6.2.3-arm64.dmg";
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
