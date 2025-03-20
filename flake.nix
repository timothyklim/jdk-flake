{
  description = "JDK's flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";

    # OpenJDK variants
    jdk21 = {
      url = "github:openjdk/jdk21u";
      flake = false;
    };
    jdk24 = {
      url = "github:openjdk/jdk24u";
      flake = false;
    };

    jdk = {
      url = "github:openjdk/jdk";
      flake = false;
    };
    # jdk-loom = {
    #   url = "github:openjdk/loom/fibers";
    #   flake = false;
    # };
    # jdk-panama = {
    #   url = "github:openjdk/panama-foreign/foreign-jextract";
    #   flake = false;
    # };
    # jdk-valhalla = {
    #   url = "github:openjdk/valhalla/lworld";
    #   flake = false;
    # };

    jtreg-src = {
      url = "github:openjdk/jtreg";
      flake = false;
    };
    jextract-src = {
      url = "github:openjdk/jextract";
      flake = false;
    };
    jmc_linux_tgz = {
      url = "https://cdn.azul.com/zmc/bin/zmc9.0.0.15-ca-linux_x64.tar.gz";
      flake = false;
    };
    visualvm_zip = {
      url = "https://github.com/oracle/visualvm/releases/download/2.1.10/visualvm_2110.zip";
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

    # jprofiler_tgz = {
    #   url = "https://download.ej-technologies.com/jprofiler/jprofiler_linux_14_0.tar.gz";
    #   flake = false;
    # };
    # yourkit_zip = {
    #   url = "https://download.yourkit.com/yjp/2023.9/YourKit-JavaProfiler-2023.9-b107-arm64.zip";
    #   flake = false;
    # };

    # Zulu
    zulu24_linux_x64_tgz = {
      url = "https://cdn.azul.com/zulu/bin/zulu24.28.83-ca-jdk24.0.0-linux_x64.tar.gz";
      flake = false;
    };
    zulu24_macos_aarch64_tgz = {
      url = "https://cdn.azul.com/zulu/bin/zulu24.28.83-ca-jdk24.0.0-macosx_aarch64.tar.gz";
      flake = false;
    };

    # Zing
    # zing21_linux_tgz = {
    #   url = "https://ftp.azul.com/releases/Zing/ZVM24.02.0.0/zing24.02.0.0-6-jdk21.0.2-linux_x64.tar.gz";
    #   flake = false;
    # };
  };

  nixConfig = {
    extra-trusted-public-keys = "nix-store.tawasal.ae:ZvppQTiNIqqt9y970LptbhrLOmqHWrIvrzkH9Qz2uJM=";
    extra-substituters = "https://nix-store.tawasal.ae/store";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , jdk21
    , jdk24
    , jdk
      # , jdk-loom
      # , jdk-panama
      # , jdk-valhalla
    , jtreg-src
    , jextract-src
    , jmc_linux_tgz
    , visualvm_zip
    , async-profiler-src
    , jattach-src
      # , jprofiler_tgz
      # , yourkit_zip
    , zulu24_linux_x64_tgz
    , zulu24_macos_aarch64_tgz
      # , zing21_linux_tgz
    }:
      with flake-utils.lib; with system; eachSystem [ x86_64-linux aarch64-linux aarch64-darwin ] (system:
      let
        sources = with builtins; (fromJSON (readFile ./flake.lock)).nodes;
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
        inherit (pkgs.stdenv.hostPlatform) isAarch;

        openjdk_21 = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk21;
          version = "21";
          jdk = pkgs.zulu21;
        };
        openjdk_21_debug = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk21;
          version = "21";
          jdk = pkgs.zulu21;
          debugSymbols = true;
        };
        openjdk_21_fastdebug = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk21;
          version = "21";
          jdk = pkgs.zulu21;
          debug = true;
        };

        openjdk_24 = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk24;
          version = "24";
          jdk = pkgs.zulu23;
        };
        openjdk_24_debug = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk24;
          version = "24";
          jdk = pkgs.zulu23;
          debugSymbols = true;
        };
        openjdk_24_fastdebug = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk24;
          version = "24";
          jdk = pkgs.zulu23;
          debug = true;
        };

        openjdk_latest = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk;
          version = "latest";
          jdk = pkgs.zulu23;
        };

        # openjdk-loom = import ./build/openjdk.nix {
        #   inherit pkgs nixpkgs;
        #   src = jdk-loom;
        #   version = "20-loom";
        #   jdk = openjdk_21;
        # };
        # openjdk-panama = import ./build/openjdk.nix {
        #   inherit pkgs nixpkgs;
        #   src = jdk-panama;
        #   version = "20-panama";
        #   nativeDeps = [ pkgs.llvmPackages.libclang ];
        #   jdk = openjdk_21;
        # };
        # openjdk-valhalla = import ./build/openjdk.nix {
        #   inherit pkgs nixpkgs;
        #   src = jdk-valhalla;
        #   version = "20-valhalla";
        #   jdk = openjdk_21;
        # };

        jtreg = import ./build/jtreg.nix {
          inherit pkgs;
          src = jtreg-src;
        };
        jextract = import ./build/jextract.nix {
          inherit pkgs;
          jdk = pkgs.zulu23;
          src = jextract-src;
        };
        jmc = import ./build/jmc.nix {
          inherit pkgs;
          src = jmc_linux_tgz;
          version = "9.0.0";
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

        # jprofiler = import ./build/jprofiler.nix {
        #   inherit pkgs;
        #   src = jprofiler_tgz;
        # };
        # yourkit = import ./build/yourkit.nix {
        #   inherit pkgs;
        #   src = yourkit_zip;
        # };

        zulu_24_linux = import ./build/zulu.nix {
          inherit pkgs;
          src = zulu24_linux_x64_tgz;
          version = "24+36";
        };
        zulu_24_macos = import ./build/zulu.nix {
          inherit pkgs;
          src = zulu24_macos_aarch64_tgz;
          version = "24+36";
        };

        # zing_21 = import ./build/zing.nix {
        #   inherit pkgs;
        #   src = zing17_linux_tgz;
        #   version = "17.0.0";
        # };

        jdk_21 = if pkgs.stdenv.isLinux then openjdk_21 else pkgs.zulu21;
        jdk_24 = if pkgs.stdenv.isLinux then openjdk_24 else zulu_24_macos;

        jdk = jdk_24;

        derivation = {
          inherit openjdk_21 openjdk_21_debug openjdk_21_fastdebug
            openjdk_24 openjdk_24_debug openjdk_24_fastdebug
            openjdk_latest
            # openjdk-loom openjdk-panama openjdk-valhalla
            jtreg jextract jmc jitwatch visualvm
            async-profiler jattach
            # jprofiler yourkit
            jdk_21 jdk_24
            # zing_21
            ;
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
