# Original version: https://discourse.nixos.org/t/feedback-darwin-installapplication/11324/3
{ lib, stdenvNoCC, xar }:

stdenvNoCC.mkDerivation rec {
  version = "1.0.0";
  pname = "unpkg";

  nativeBuildInputs = [ xar ];
  setupHook = ./setup-hook.sh;

  src = ./.;

  installPhase = ''
    mkdir -p $out/bin
    ln -s $(command -v xar) $out/bin/xar
  '';

  meta = with lib; {
    description = "Extract a pkg file";
    license = licenses.gpl3;
    platforms = platforms.all;
    maintainers = with maintainers; [ spease ];
  };
}
