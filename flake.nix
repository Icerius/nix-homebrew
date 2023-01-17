{
  description = "Homebrew casks 2 nix";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils, ... }:
    let
      overlay = import ./overlay.nix;
    in
    flake-utils.lib.eachSystem [
      flake-utils.lib.system.x86_64-darwin
      flake-utils.lib.system.aarch64-darwin
    ]
      (system:
        let
          overlays = [ overlay ];
          pkgs = import nixpkgs {
            inherit
              overlays
              system
              ;
          };
        in
        {

          checks = {
            inherit (pkgs.casks)
              ferdium
              jetbrains-toolbox
              amethyst
              alt-tab
              choosy
              ;
            inherit (pkgs) unpkg;
          };
          packages = pkgs.casks;
          devShell = (import ./shell.nix) {
            inherit pkgs;
          };
        }
      ) // {
      inherit overlay;
      overlays = {
        default = overlay;
      };
    };
}
