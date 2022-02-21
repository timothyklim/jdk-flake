{
  description = "JDK's flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
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
    jdk18 = {
      url = "github:openjdk/jdk18u";
      flake = false;
    };

    jdk-loom = {
      url = "github:openjdk/loom/fibers";
      flake = false;
    };
    jdk-panama = {
      url = "github:openjdk/panama-foreign/foreign-jextract";
      flake = false;
    };
    jdk-valhalla = {
      url = "github:openjdk/valhalla/lworld";
      flake = false;
    };

    # Zulu    
    zulu17_linux_tgz = {
      url = "https://cdn.azul.com/zulu/bin/zulu17.30.15-ca-jdk17.0.1-linux_x64.tar.gz";
      flake = false;
    };
    zulu17_macos_tgz = {
      url = "https://cdn.azul.com/zulu/bin/zulu17.30.15-ca-jdk17.0.1-macosx_x64.tar.gz";
      flake = false;
    };

    # Zing
    zing17_linux_tgz = {
      url = "https://cdn.azul.com/zing-zvm/ZVM22.01.1.0/zing22.01.1.0-1-jdk17.0.2-linux_x64.tar.gz";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, jdk16, jdk17, jdk18, jdk-loom, jdk-panama, jdk-valhalla, zulu17_linux_tgz, zulu17_macos_tgz, zing17_linux_tgz }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ] (system:
      let
        sources = with builtins; (fromJSON (readFile ./flake.lock)).nodes;
        pkgs = nixpkgs.legacyPackages.${system};

        zing_17 = import ./build/zing.nix {
          inherit pkgs;
          src = zing17_linux_tgz;
          version = "17.0.0";
        };

        zulu_17 = import ./build/zulu.nix {
          inherit pkgs;
          src = if pkgs.stdenv.isLinux then zulu17_linux_tgz else zulu17_macos_tgz;
          version = "17.0.0";
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

        openjdk_18 = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk18;
          version = "18";
          jdk = openjdk_17;
        };
        openjdk_18-loom = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk-loom;
          version = "18-loom";
          jdk = openjdk_17;
        };
        openjdk_18-panama = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk-panama;
          version = "18-panama";
          nativeDeps = [ pkgs.llvmPackages.libclang ];
          jdk = openjdk_17;
        };
        openjdk_18-valhalla = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk-valhalla;
          version = "18-valhalla";
          jdk = openjdk_17;
        };

        jdk_17 = if pkgs.stdenv.isLinux then openjdk_17 else zulu_17;

        derivation = {
          inherit openjdk_17 openjdk_18 openjdk_18-loom openjdk_18-panama openjdk_18-valhalla zulu_17 zing_17 jdk_17;
        };
      in
      rec {
        packages = derivation;
        defaultPackage = jdk_17;
        devShell = pkgs.callPackage ./shell.nix derivation;
      });
}
