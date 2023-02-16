{
  lib,
  pkgs,
}: let
  caskApp = pkgs.callPackage ./caskApp.nix;
  casks = lib.importJSON ./cask.json;
  # Some apps do not contain a valid sha256 hash
  validCasks = builtins.filter (e: e.sha256 != "no_check") casks;

  apps = builtins.listToAttrs (builtins.map (c: {
      name = c.token;
      value = c;
    })
    validCasks);
in
  lib.attrsets.mapAttrs
  (name: cask:
    caskApp {
      inherit cask;
    })
  apps
