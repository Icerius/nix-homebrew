{ stdenvNoCC, lib, fetchurl, undmg, unpkg, cask, system }:
let
  # curl -o packages/brewCasks/cask.json https://formulae.brew.sh/api/cask.json
  isArm = system == "aarch64-darwin";
  hasVariation = isArm && cask.variations ? "arm64_ventura" && cask.variations.arm64_ventura ? "url";
  version = lib.lists.last (builtins.split "," cask.version);
  pname = cask.token;
  inherit (if hasVariation then cask.variations.arm64_big_sur else cask) url sha256;
  src = fetchurl {
    inherit url sha256;
    name = builtins.replaceStrings [ "%20" "(" ")" "%" "&" "!" "#" "@" ] [ "_" "" "" "" "" "" "" ""] (builtins.baseNameOf url);
  };
in
stdenvNoCC.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    undmg
    unpkg
  ];

  sourceRoot = ".";
  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    mkdir -p $out/Applications
    cp -R *.app $out/Applications/
  '';

  meta.platforms = lib.platforms.darwin;
}
