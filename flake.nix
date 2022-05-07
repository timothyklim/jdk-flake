{
  description = "JDK's flake";

  inputs = {
    nixpkgs.url = "nixpkgs/release-21.11";

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

    jdk = {
      url = "github:openjdk/jdk";
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

    zulu18_linux_tgz = {
      url = "https://cdn.azul.com/zulu/bin/zulu18.28.13-ca-jdk18.0.0-linux_x64.tar.gz";
      flake = false;
    };

    # Zing
    zing17_linux_tgz = {
      url = "https://cdn.azul.com/zing-zvm/ZVM22.01.1.0/zing22.01.1.0-1-jdk17.0.2-linux_x64.tar.gz";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, jdk16, jdk17, jdk18, jdk, jdk-loom, jdk-panama, jdk-valhalla, zulu17_linux_tgz, zulu18_linux_tgz, zing17_linux_tgz }:
      let
        system = "x86_64-linux";
        sources = with builtins; (fromJSON (readFile ./flake.lock)).nodes;
        pkgs = nixpkgs.legacyPackages.${system};

        zing_17 = import ./build/zing.nix {
          inherit pkgs;
          src = zing17_linux_tgz;
          version = "17.0.0";
        };

        zulu_17 = import ./build/zulu.nix {
          inherit pkgs;
          src = zulu17_linux_tgz;
          version = "17.0.0";
        };

        zulu_18 = import ./build/zulu.nix {
          inherit pkgs;
          src = zulu18_linux_tgz;
          version = "18.0.0";
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

        openjdk = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk;
          version = "19";
          jdk = openjdk_18;
        };
        openjdk-loom = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk-loom;
          version = "19-loom";
          jdk = openjdk_18;
        };
        openjdk-panama = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk-panama;
          version = "19-panama";
          nativeDeps = [ pkgs.llvmPackages.libclang ];
          jdk = openjdk_18;
        };
        openjdk-valhalla = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk-valhalla;
          version = "19-valhalla";
          jdk = openjdk_18;
        };

        jdk_17 = if pkgs.stdenv.isLinux then openjdk_17 else zulu_17;
        jdk_18 = if pkgs.stdenv.isLinux then openjdk_18 else zulu_18;

        derivation = {
          inherit openjdk_17 openjdk_18 openjdk openjdk-loom openjdk-panama openjdk-valhalla zulu_17 zulu_18 zing_17 jdk_17 jdk_18;
        };
      in
      rec {
        packages.${system} = derivation;
        defaultPackage.${system} = jdk_18;
        devShell.${system} = pkgs.callPackage ./shell.nix derivation;
      };
}
