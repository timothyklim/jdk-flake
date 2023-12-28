{
  description = "JDK's flake";

  inputs = {
    nixpkgs.url = "nixpkgs/release-23.11";
    flake-utils.url = "github:numtide/flake-utils";

    # OpenJDK variants
    jdk17 = {
      url = "github:openjdk/jdk17u";
      flake = false;
    };
    jdk21 = {
      url = "github:openjdk/jdk21u";
      flake = false;
    };
    jdk22 = {
      url = "github:openjdk/jdk22u";
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

    jtreg-src = {
      url = "github:openjdk/jtreg";
      flake = false;
    };
    jextract-src = {
      url = "github:openjdk/jextract";
      flake = false;
    };
    jextract_jdk22-src = {
      url = "github:openjdk/jextract/jdk22";
      flake = false;
    };
    jmc_linux_tgz = {
      url = "https://download.java.net/java/GA/jmc8/05/binaries/jmc-8.3.1_linux-x64.tar.gz";
      flake = false;
    };
    visualvm_zip = {
      url = "https://github.com/oracle/visualvm/releases/download/2.1.7/visualvm_217.zip";
      flake = false;
    };

    async-profiler-src = {
      url = "github:jvm-profiling-tools/async-profiler";
      flake = false;
    };
    jattach-src = {
      url = "github:jattach/jattach";
      flake = false;
    };

    jprofiler_tgz = {
      url = "https://download.ej-technologies.com/jprofiler/jprofiler_linux_14_0.tar.gz";
      flake = false;
    };
    yourkit_zip = {
      url = "https://download.yourkit.com/yjp/2023.9/YourKit-JavaProfiler-2023.9-b102-arm64.zip";
      flake = false;
    };

    # Zulu    
    zulu17_linux_tgz = {
      url = "https://cdn.azul.com/zulu/bin/zulu17.30.15-ca-jdk17.0.1-linux_x64.tar.gz";
      flake = false;
    };
    zulu21_linux_x64_tgz = {
      url = "https://cdn.azul.com/zulu/bin/zulu21.30.15-ca-jdk21.0.1-linux_x64.tar.gz";
      flake = false;
    };
    zulu21_linux_aarch64_tgz = {
      url = "https://cdn.azul.com/zulu/bin/zulu21.30.15-ca-jdk21.0.1-linux_aarch64.tar.gz";
      flake = false;
    };
    zulu21_macos_aarch64_tgz = {
      url = "https://cdn.azul.com/zulu/bin/zulu21.30.15-ca-jdk21.0.1-macosx_aarch64.tar.gz";
      flake = false;
    };

    # Zing
    zing17_linux_tgz = {
      url = "https://cdn.azul.com/zing-zvm/ZVM22.01.1.0/zing22.01.1.0-1-jdk17.0.2-linux_x64.tar.gz";
      flake = false;
    };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , jdk17
    , jdk21
    , jdk22
    , jdk
    , jdk-loom
    , jdk-panama
    , jdk-valhalla
    , jtreg-src
    , jextract-src
    , jextract_jdk22-src
    , jmc_linux_tgz
    , visualvm_zip
    , async-profiler-src
    , jattach-src
    , jprofiler_tgz
    , yourkit_zip
    , zulu17_linux_tgz
    , zulu21_linux_x64_tgz
    , zulu21_linux_aarch64_tgz
    , zulu21_macos_aarch64_tgz
    , zing17_linux_tgz
    }:
      with flake-utils.lib; eachSystem [ system.x86_64-linux system.aarch64-linux system.aarch64-darwin ] (system:
      let
        sources = with builtins; (fromJSON (readFile ./flake.lock)).nodes;
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs.stdenv.hostPlatform) isAarch;

        openjdk_17 = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk17;
          version = "17";
        };
        openjdk_21 = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk21;
          version = "21";
          jdk = zulu_21_linux;
        };
        openjdk_21_debug = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk21;
          version = "21";
          jdk = zulu_21_linux;
          debugSymbols = true;
        };
        openjdk_21_fastdebug = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk21;
          version = "21";
          jdk = zulu_21_linux;
          debug = true;
        };
        openjdk_22 = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk22;
          version = "22";
          jdk = zulu_21_linux;
        };
        openjdk_22_debug = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk22;
          version = "22";
          jdk = zulu_21_linux;
          debugSymbols = true;
        };
        openjdk_22_fastdebug = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk22;
          version = "22";
          jdk = zulu_21_linux;
          debug = true;
        };
        openjdk_latest = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk;
          version = "latest";
          jdk = zulu_21_linux;
        };

        openjdk-loom = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk-loom;
          version = "20-loom";
          jdk = openjdk_21;
        };
        openjdk-panama = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk-panama;
          version = "20-panama";
          nativeDeps = [ pkgs.llvmPackages.libclang ];
          jdk = openjdk_21;
        };
        openjdk-valhalla = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk-valhalla;
          version = "20-valhalla";
          jdk = openjdk_21;
        };

        jtreg = import ./build/jtreg.nix {
          inherit pkgs;
          src = jtreg-src;
        };
        jextract = import ./build/jextract.nix {
          inherit pkgs openjdk_21 jtreg;
          src = jextract-src;
        };
        jextract_jdk22 = import ./build/jextract.nix {
          inherit pkgs openjdk_22 jtreg;
          src = jextract_jdk22-src;
        };
        jmc = import ./build/jmc.nix {
          inherit pkgs;
          src = jmc_linux_tgz;
          version = "8.2.1";
        };
        jitwatch = import ./build/jitwatch.nix { inherit pkgs; };
        visualvm = import ./build/visualvm.nix {
          inherit pkgs;
          src = visualvm_zip;
          version = "2.1.4";
        };

        async-profiler = import ./build/async-profiler.nix {
          inherit pkgs;
          jdk = pkgs.openjdk_headless;
          src = async-profiler-src;
        };
        jattach = import ./build/jattach.nix {
          inherit pkgs;
          src = jattach-src;
        };

        jprofiler = import ./build/jprofiler.nix {
          inherit pkgs;
          src = jprofiler_tgz;
        };
        yourkit = import ./build/yourkit.nix {
          inherit pkgs;
          src = yourkit_zip;
        };

        zulu_17 = import ./build/zulu.nix {
          inherit pkgs;
          src = zulu17_linux_tgz;
          version = "17.0.0";
        };
        zulu_21_linux = import ./build/zulu.nix {
          inherit pkgs;
          src = if isAarch then zulu21_linux_aarch64_tgz else zulu21_linux_x64_tgz;
          version = "21.0.1";
        };
        zulu_21_macos = import ./build/zulu.nix {
          inherit pkgs;
          src = zulu21_macos_aarch64_tgz;
          version = "21.0.1";
        };

        zing_17 = import ./build/zing.nix {
          inherit pkgs;
          src = zing17_linux_tgz;
          version = "17.0.0";
        };

        jdk_17 = if pkgs.stdenv.isLinux then openjdk_17 else zulu_17;
        jdk_21 = if pkgs.stdenv.isLinux then openjdk_21 else zulu_21_macos;
        jdk_22 = openjdk_22; # if pkgs.stdenv.isLinux then openjdk_22 else zulu_22;

        jdk = openjdk_21;

        derivation = {
          inherit openjdk_17
            openjdk_21 openjdk_21_debug openjdk_21_fastdebug
            openjdk_22 openjdk_22_debug openjdk_22_fastdebug
            openjdk_latest openjdk-loom openjdk-panama openjdk-valhalla
            jtreg jextract jextract_jdk22 jmc jitwatch visualvm
            async-profiler jattach
            jprofiler yourkit
            zulu_17 zing_17 jdk_17 jdk_21 jdk_22;
        };
      in
      rec {
        packages = derivation;
        devShell = pkgs.callPackage ./shell.nix derivation;
        nixosModule = {
          environment.systemPackages = [ jdk ];
          programs.java.package = jdk;
          nixpkgs.overlays = [ overlay ];
        };
        overlay = final: prev: derivation;
        formatter = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
      });
}
