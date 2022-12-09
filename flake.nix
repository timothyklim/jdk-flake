{
  description = "JDK's flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.11";

    # OpenJDK variants
    jdk17 = {
      url = "github:openjdk/jdk17u";
      flake = false;
    };
    jdk18 = {
      url = "github:openjdk/jdk18u";
      flake = false;
    };
    jdk19 = {
      url = "github:openjdk/jdk19u";
      flake = false;
    };
    jdk20 = {
      url = "github:openjdk/jdk20";
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
    jmc_linux_tgz = {
      url = "https://download.java.net/java/GA/jmc8/03/binaries/jmc-8.2.1_linux-x64.tar.gz";
      flake = false;
    };
    visualvm_zip = {
      url = "https://github.com/oracle/visualvm/releases/download/2.1.4/visualvm_214.zip";
      flake = false;
    };

    async-profiler-src = {
      url = "github:jvm-profiling-tools/async-profiler/v2.9";
      flake = false;
    };

    jprofiler_tgz = {
      url = "https://download.ej-technologies.com/jprofiler/jprofiler_linux_13_0_3.tar.gz";
      flake = false;
    };
    yourkit_zip = {
      url = "https://download.yourkit.com/yjp/2022.9/YourKit-JavaProfiler-2022.9-b171.zip";
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
    zulu19_linux_tgz = {
      url = "https://cdn.azul.com/zulu/bin/zulu19.30.11-ca-jdk19.0.1-linux_x64.tar.gz";
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
    , jdk17
    , jdk18
    , jdk19
    , jdk20
    , jdk
    , jdk-loom
    , jdk-panama
    , jdk-valhalla
    , jtreg-src
    , jextract-src
    , jmc_linux_tgz
    , visualvm_zip
    , async-profiler-src
    , jprofiler_tgz
    , yourkit_zip
    , zulu17_linux_tgz
    , zulu18_linux_tgz
    , zulu19_linux_tgz
    , zing17_linux_tgz
    }:
    let
      system = "x86_64-linux";
      sources = with builtins; (fromJSON (readFile ./flake.lock)).nodes;
      pkgs = nixpkgs.legacyPackages.${system};

      openjdk_17 = import ./build/openjdk.nix {
        inherit pkgs nixpkgs;
        src = jdk17;
        version = "17";
      };
      openjdk_18 = import ./build/openjdk.nix {
        inherit pkgs nixpkgs;
        src = jdk18;
        version = "18";
        jdk = zulu_17;
      };
      openjdk_19 = import ./build/openjdk.nix {
        inherit pkgs nixpkgs;
        src = jdk19;
        version = "19";
        jdk = zulu_18;
      };
      openjdk_20 = import ./build/openjdk.nix {
        inherit pkgs nixpkgs;
        src = jdk20;
        version = "20";
        jdk = zulu_19;
      };

      openjdk = import ./build/openjdk.nix {
        inherit pkgs nixpkgs;
        src = jdk;
        version = "20";
        jdk = openjdk_19;
      };
      openjdk-loom = import ./build/openjdk.nix {
        inherit pkgs nixpkgs;
        src = jdk-loom;
        version = "20-loom";
        jdk = openjdk_19;
      };
      openjdk-panama = import ./build/openjdk.nix {
        inherit pkgs nixpkgs;
        src = jdk-panama;
        version = "20-panama";
        nativeDeps = [ pkgs.llvmPackages.libclang ];
        jdk = openjdk_19;
      };
      openjdk-valhalla = import ./build/openjdk.nix {
        inherit pkgs nixpkgs;
        src = jdk-valhalla;
        version = "20-valhalla";
        jdk = openjdk_19;
      };

      jtreg = import ./build/jtreg.nix {
        inherit pkgs;
        src = jtreg-src;
      };
      jextract = import ./build/jextract.nix {
        inherit pkgs openjdk_19 jtreg;
        src = jextract-src;
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
        jdk = openjdk_19;
        src = async-profiler-src;
        version = sources.async-profiler-src.original.ref;
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
      zulu_18 = import ./build/zulu.nix {
        inherit pkgs;
        src = zulu18_linux_tgz;
        version = "18.0.0";
      };
      zulu_19 = import ./build/zulu.nix {
        inherit pkgs;
        src = zulu19_linux_tgz;
        version = "19.0.1";
      };

      zing_17 = import ./build/zing.nix {
        inherit pkgs;
        src = zing17_linux_tgz;
        version = "17.0.0";
      };

      jdk_17 = if pkgs.stdenv.isLinux then openjdk_17 else zulu_17;
      jdk_18 = if pkgs.stdenv.isLinux then openjdk_18 else zulu_18;
      jdk_19 = if pkgs.stdenv.isLinux then openjdk_19 else zulu_19;

      jdk = openjdk_19;

      derivation = {
        inherit openjdk_17 openjdk_18 openjdk_19 openjdk_20 openjdk
          openjdk-loom openjdk-panama openjdk-valhalla
          jtreg jextract jmc jitwatch visualvm
          async-profiler
          jprofiler yourkit
          zulu_17 zulu_18 zing_17 jdk_17 jdk_18 jdk_19;
      };
    in
    rec {
      packages.${system} = derivation // { default = jdk; };
      devShells.${system}.default = pkgs.callPackage ./shell.nix { inherit jdk; };
      nixosModules.default = {
        environment.systemPackages = [ jdk ];
        programs.java.package = jdk;
        nixpkgs.overlays = [ overlays.default ];
      };
      overlays.default = final: prev: derivation;
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
    };
}
