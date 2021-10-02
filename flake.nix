{
  description = "JDK's flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # OpenJDK variants
    jdk16 = {
      url = "github:openjdk/jdk16u";
      flake = false;
    };
    jdk17 = {
      url = "github:openjdk/jdk17u";
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

    # Zulu    
    zulu17_linux_tgz = {
      url = "https://cdn.azul.com/zulu/bin/zulu17.28.13-ca-jdk17.0.0-linux_x64.tar.gz";
      flake = false;
    };
    zulu17_macos_tgz = {
      url = "https://cdn.azul.com/zulu/bin/zulu17.28.13-ca-jdk17.0.0-macosx_x64.tar.gz";
      flake = false;
    };

    # Zing
    zing15_linux_tgz = {
      url = "https://cdn.azul.com/zing-zvm/feature-preview/zing99.99.99.99-fp.dev-3441-jdk15.0.1.tar.gz";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, jdk16, jdk17, jdk17-loom, jdk17-panama, jdk17-valhalla, jdk18, zulu17_linux_tgz, zulu17_macos_tgz, zing15_linux_tgz }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ] (system:
      let
        sources = with builtins; (fromJSON (readFile ./flake.lock)).nodes;
        pkgs = nixpkgs.legacyPackages.${system};

        zulu_17 = import ./build/zulu.nix {
          inherit pkgs;
          src = if pkgs.stdenv.isLinux then zulu17_linux_tgz else zulu17_macos_tgz;
          version = "17.0.0";
        };

        zing_15 = import ./build/zing.nix {
          inherit pkgs;
          src = zing15_linux_tgz;
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
        openjdk_17-panama = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk17-panama;
          version = "17-panama";
          nativeDeps = [ pkgs.llvmPackages.libclang ];
        };
        openjdk_17-valhalla = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk17-valhalla;
          version = "17-valhalla";
        };
        openjdk_18 = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk18;
          version = "18";
          jdk = openjdk_17;
        };

        jdk_17 = if pkgs.stdenv.isLinux then openjdk_17 else zulu_17;

        derivation = {
          inherit openjdk_16 openjdk_17 openjdk_17-loom openjdk_17-panama openjdk_17-valhalla openjdk_18 zulu_17 zing_15 jdk_17;
        };
      in
      rec {
        packages = derivation;
        defaultPackage = jdk_17;
        devShell = pkgs.callPackage ./shell.nix derivation;
      });
}
