{
  stdenvNoCC,
  lib,
  fetchurl,
  unpkg,
  cask,
  system,
  libplist,
  jq,
  file,
}:
let
  # curl -o packages/brewCasks/cask.json https://formulae.brew.sh/api/cask.json
  isArm = system == "aarch64-darwin";
  codeName = "sequoia";
  variation = if isArm then "arm64_${codeName}" else codeName;
  hasVariation = cask.variations ? "${variation}" && cask.variations."${variation}" ? "url" && cask.variations."${variation}" ? "sha256";
  version = lib.lists.last (builtins.split "," cask.version);
  pname = builtins.replaceStrings [ "@" ] [ "_" ] cask.token;
  inherit (if hasVariation then cask.variations."${variation}" else cask) url sha256;
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

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  doCheck = true;
  dontFixup = true;

  installPhase = ''
    mkdir -p $out/Applications
    cp -R *.app $out/Applications/
  '';

  checkPhase =
    let
      execArch = if isArm then "arm64 executable" else "x86_64 executable";
    in
    ''
      for folder in *; do
        if [[ "$folder" =~ \.app$ ]]; then 
          executable=$(${lib.getExe libplist} -i "$(realpath "$folder")/Contents/Info.plist" -f json | ${lib.getExe jq} -r .CFBundleExecutable)
          app="$folder/Contents/MacOS/$executable"
          appInfo=$(${lib.getExe file} "$app")
          echo Info $appInfo
          if echo $appInfo | grep -q "universal"; then
            echo "Executable $app is universal"
          elif echo $appInfo | grep -q "${execArch}"; then
            echo "Executable $app is valid for $execArch"
          else
            echo "Executable $app is not valid for ${system}"
            exit 1
          fi
        fi
      done
    '';

  meta.platforms = lib.platforms.darwin;
}
