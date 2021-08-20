{
  description = "JDK's flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/staging-21.05";

    zing_15-pkg = {
      url = "https://cdn.azul.com/zing-zvm/feature-preview/zing99.99.99.99-fp.dev-3441-jdk15.0.1.tar.gz";
      flake = false;
    };

    # OpenJDK variants

    jdk16 = {
      url = "github:openjdk/jdk16";
      flake = false;
    };

    jdk17 = {
      url = "github:openjdk/jdk17";
      flake = false;
    };
    jdk17-loom = {
      url = "github:openjdk/loom/fibers";
      flake = false;
    };
    jdk17-panama = {
      url = "github:openjdk/panama-foreign/foreign-jextract";
      flake = false;
    };
    jdk17-valhalla = {
      url = "github:openjdk/valhalla/lworld";
      flake = false;
    };

    jdk18 = {
      url = "github:openjdk/jdk";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, zing_15-pkg, jdk16, jdk17, jdk17-loom, jdk17-panama, jdk17-valhalla, jdk18 }:
    let
      sources = with builtins; (fromJSON (readFile ./flake.lock)).nodes;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      zing_15 = import ./build/zing.nix {
        inherit pkgs;
        src = zing_15-pkg;
        version = "15.0.3";
      };

      openjdk_16 = import ./build/openjdk.nix {
        inherit pkgs nixpkgs;
        src = jdk16;
        version = "16";
        patchInstall = true;
      };
      openjdk_17 = import ./build/openjdk.nix {
        inherit pkgs nixpkgs;
        src = jdk17;
        version = "17";
      };
      openjdk_17-loom = import ./build/openjdk.nix {
        inherit pkgs nixpkgs;
        src = jdk17-loom;
        version = "17-loom";
      };
      # openjdk_17-panama = import ./build/openjdk.nix {
      #   inherit pkgs nixpkgs;
      #   src = jdk17-panama;
      #   version = "17-panama";
      #   nativeDeps = [ pkgs.llvmPackages.libclang ];
      # };
      openjdk_17-valhalla = import ./build/openjdk.nix {
        inherit pkgs nixpkgs;
        src = jdk17-valhalla;
        version = "17-valhalla";
      };
      openjdk_18 = import ./build/openjdk.nix {
        inherit pkgs nixpkgs;
        src = jdk18;
        version = "18";
      };

      derivation = {
        inherit zing_15 openjdk_16 openjdk_17 openjdk_17-loom openjdk_17-valhalla openjdk_18;
      };
    in
    rec {
      packages.${system} = derivation;
      defaultPackage.${system} = jdk17;
      legacyPackages.${system} = pkgs.extend overlay;
      devShell.${system} = pkgs.callPackage ./shell.nix derivation;
      nixosModule.nixpkgs.overlays = [ overlay ];
      overlay = final: prev: derivation;
    };
}
