{ stdenvNoCC, lib, fetchurl, undmg, unzip, unpkg, cask }:
let
  # curl -o packages/brewCasks/cask.json https://formulae.brew.sh/api/cask.json
  version = lib.lists.last (builtins.split "," cask.version);
  pname = cask.token;
  nameApp = "${pname}.app";
  src = fetchurl {
    url = cask.url;
    sha256 = cask.sha256;
    name = builtins.replaceStrings [ "%20" "(" ")" "%" "&" "!" "#" ] [ "_" "" "" "" "" "" "" ] (builtins.baseNameOf cask.url);
  };
in
stdenvNoCC.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    undmg
    unzip
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
