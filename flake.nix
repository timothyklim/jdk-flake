{
  description = "Azul Zing 15 Feature Preview flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    # Azul Zing
    zing-pkg = {
      url = "https://cdn.azul.com/zing-zvm/feature-preview/zing99.99.99.99-fp.dev-3418-jdk15.0.1.tar.gz";
      flake = false;
    };

    # OpenJDK variants
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

  outputs = { self, nixpkgs, flake-compat, zing-pkg, jdk16, jdk17, jdk17-loom, jdk17-valhalla }:
    let
      sources = with builtins; (fromJSON (readFile ./flake.lock)).nodes;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      zing = import ./build/zing.nix {
        inherit pkgs;
        src = zing-pkg;
      };

      openjdk_16 = import ./build/openjdk.nix {
        inherit pkgs;
        src = jdk16;
        version = "16-ga";
        patch = true;
      };
      openjdk_17 = import ./build/openjdk.nix {
        inherit pkgs;
        src = jdk17;
        version = "17-15";
      };
      openjdk_17-fibers = import ./build/openjdk.nix {
        inherit pkgs;
        src = jdk17-loom;
        version = "17-fibers";
      };
      openjdk_17-valhalla = import ./build/openjdk.nix {
        inherit pkgs;
        src = jdk17-valhalla;
        version = "17-valhalla";
      };

      mkApp = drv: {
        type = "app";
        program = "${drv.pname or drv.name}${drv.passthru.exePath}";
      };

      derivation = {
        inherit zing openjdk_16 openjdk_17 openjdk_17-fibers openjdk_17-valhalla;
      };
    in
    rec {
      packages.${system} = derivation;
      defaultPackage.${system} = zing;
      apps.${system} = {
        zing = mkApp { drv = zing; };

        openjdk_16 = mkApp { drv = openjdk_16; };
        openjdk_17 = mkApp { drv = openjdk_17; };
        openjdk_17-fibers = mkApp { drv = openjdk_17-fibers; };
        openjdk_17-valhalla = mkApp { drv = openjdk_17-valhalla; };
      };
      defaultApp.${system} = apps.zing;
      legacyPackages.${system} = pkgs.extend overlay;
      devShell.${system} = pkgs.callPackage ./shell.nix derivation;
      nixosModule.nixpkgs.overlays = [ overlay ];
      overlay = final: prev: derivation;
    };
}
