{
  description = "Homebrew casks 2 nix";

  outputs = { self, nixpkgs, ... }:
    let
      overlay = import ./overlay.nix;
      system = "x86_64-darwin";
      overlays = [ overlay ];
      pkgs = import nixpkgs {
        inherit
          overlays
          system
          ;
      };
    in
    {
      inherit overlay;
      checks.${system} = {
        inherit (pkgs.casks)
          ferdi
          jetbrains-toolbox
          amethyst
          alt-tab
          #choosy # Broken, double unpack needed
          ;
        inherit (pkgs) unpkg;
      };
      packages.${system} = pkgs.casks;
      devShell.${system} = (import ./shell.nix) {
        inherit pkgs;
      };
    };
}
