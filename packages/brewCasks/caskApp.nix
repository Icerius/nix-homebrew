{ stdenvNoCC, lib, fetchurl, unpkg, cask, system }:
let
  # curl -o packages/brewCasks/cask.json https://formulae.brew.sh/api/cask.json
  isArm = system == "aarch64-darwin";
  hasVariation = isArm && cask.variations ? "arm64_sequoia" && cask.variations.arm64_sequoia ? "url";
  version = lib.lists.last (builtins.split "," cask.version);
  pname = builtins.replaceStrings ["@"] ["_"] cask.token;
  inherit (if hasVariation then cask.variations.arm64_sequoia else cask) url sha256;
  src = fetchurl {
    inherit url sha256;
  };
in
stdenvNoCC.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    unpkg
  ];

  sourceRoot = ".";
  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    mkdir -p $out/Applications
    ls -l
    cp -R *.app $out/Applications/
  '';

  meta.platforms = lib.platforms.darwin;
}
