{
  description = "Azul Zing 15 Feature Preview flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    src = {
      url = "https://cdn.azul.com/zing-zvm/feature-preview/zing99.99.99.99-fp.dev-3382-jdk15.0.1.tar.gz";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-compat, src }:
    let
      sources = with builtins; (fromJSON (readFile ./flake.lock)).nodes;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      zing = import ./build.nix {
        inherit pkgs src;
      };
      mkApp = drv: {
        type = "app";
        program = "${drv.pname or drv.name}${drv.passthru.exePath}";
      };
      derivation = { inherit zing; };
    in
    rec {
      packages.${system} = derivation;
      defaultPackage.${system} = zing;
      apps.${system}.zing = mkApp { drv = zing; };
      defaultApp.${system} = apps.zing;
      legacyPackages.${system} = pkgs.extend overlay;
      devShell.${system} = pkgs.callPackage ./shell.nix derivation;
      nixosModule.nixpkgs.overlays = [ overlay ];
      overlay = final: prev: derivation;
    };
}
