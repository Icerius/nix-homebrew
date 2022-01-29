final: prev:
{
  casks = (import ./packages/brewCasks) { inherit (final) lib pkgs; };
  unpkg = prev.callPackage ./packages/unpkg { };
}
