{
  description = "Azul Zing 15 Feature Preview flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    zing_15-pkg = {
      url = "https://cdn.azul.com/zing-zvm/feature-preview/zing99.99.99.99-fp.dev-3433-jdk15.0.1.tar.gz";
      flake = false;
    };

    # OpenJDK variants

    jdk15 = {
      url = "github:openjdk/jdk/jdk-15-ga";
      flake = false;
    };
    jdk16 = {
      url = "github:openjdk/jdk/jdk-16-ga";
      flake = false;
    };

    jdk17 = {
      url = "github:openjdk/jdk/623f0b6b"; # jdk-17+15
      flake = false;
    };
    jdk17-loom = {
      url = "github:openjdk/loom/fibers";
      flake = false;
    };
    jdk17-valhalla = {
      url = "github:openjdk/valhalla/lworld";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-compat, zing_15-pkg, jdk15, jdk16, jdk17, jdk17-loom, jdk17-valhalla }:
    let
      sources = with builtins; (fromJSON (readFile ./flake.lock)).nodes;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      zing_15 = import ./build/zing.nix {
        inherit pkgs;
        src = zing_15-pkg;
        version = "15.0.1-fp";
      };

      openjdk_15 = import ./build/openjdk.nix {
        inherit pkgs;
        src = jdk15;
        version = "15-ga";
        patchInstall = true;
      };
      openjdk_16 = import ./build/openjdk.nix {
        inherit pkgs;
        src = jdk16;
        version = "16-ga";
        patchInstall = true;
      };
      openjdk_17 = import ./build/openjdk.nix {
        inherit pkgs;
        src = jdk17;
        version = "17-15";
      };
      openjdk_17-loom = import ./build/openjdk.nix {
        inherit pkgs;
        src = jdk17-loom;
        version = "17-loom";
      };
      openjdk_17-valhalla = import ./build/openjdk.nix {
        inherit pkgs;
        src = jdk17-valhalla;
        version = "17-valhalla";
      };

      derivation = {
        inherit zing_15 openjdk_15 openjdk_16 openjdk_17 openjdk_17-loom openjdk_17-valhalla;
      };
    in
    rec {
      packages.${system} = derivation;
      defaultPackage.${system} = zing_15;
      legacyPackages.${system} = pkgs.extend overlay;
      devShell.${system} = pkgs.callPackage ./shell.nix derivation;
      nixosModule.nixpkgs.overlays = [ overlay ];
      overlay = final: prev: derivation;
    };
}
