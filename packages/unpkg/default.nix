# Original version: https://discourse.nixos.org/t/feedback-darwin-installapplication/11324/3
{ lib, stdenvNoCC, xar, unzip, cpio }:

stdenvNoCC.mkDerivation rec {
  version = "1.0.0";
  pname = "unpkg";

  nativeBuildInputs = [ xar unzip cpio ];
  setupHook = ./setup-hook.sh;

  src = ./.;

  installPhase = ''
    mkdir -p $out/bin
    ln -s $(command -v xar) $out/bin/xar
    ln -s $(command -v unzip) $out/bin/unzip
    ln -s $(command -v cpio) $out/bin/cpio
  '';

  meta = with lib; {
    description = "Extract a pkg file";
    license = licenses.gpl3;
    platforms = platforms.all;
    maintainers = with maintainers; [ spease ];
  };
}
