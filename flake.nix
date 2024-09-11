{
  description = "JDK's flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";

    # OpenJDK variants
    jdk21 = {
      url = "github:openjdk/jdk21u";
      flake = false;
    };
    jdk23 = {
      url = "github:openjdk/jdk23u";
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
      url = "https://download.java.net/java/GA/jmc8/05/binaries/jmc-8.3.1_linux-x64.tar.gz";
      flake = false;
    };
    visualvm_zip = {
      url = "https://github.com/oracle/visualvm/releases/download/2.1.8/visualvm_218.zip";
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
    zulu22_linux_x64_tgz = {
      url = "https://cdn.azul.com/zulu/bin/zulu22.30.13-ca-jdk22.0.1-linux_x64.tar.gz";
      flake = false;
    };
    zulu22_linux_aarch64_tgz = {
      url = "https://cdn.azul.com/zulu/bin/zulu22.30.13-ca-jdk22.0.1-linux_aarch64.tar.gz";
      flake = false;
    };
    zulu22_macos_aarch64_tgz = {
      url = "https://cdn.azul.com/zulu/bin/zulu22.30.13-ca-jdk22.0.1-macosx_aarch64.tar.gz";
      flake = false;
    };

    zulu23_macos_aarch64_zip = {
      url = "https://cdn.azul.com/zulu/bin/zulu23.0.79-beta-jdk23.0.0-beta.36-macosx_aarch64.zip";
      flake = false;
    };

    # Zing
    # zing21_linux_tgz = {
    #   url = "https://ftp.azul.com/releases/Zing/ZVM24.02.0.0/zing24.02.0.0-6-jdk21.0.2-linux_x64.tar.gz";
    #   flake = false;
    # };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , jdk21
    , jdk23
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
    , zulu22_linux_aarch64_tgz
    , zulu22_linux_x64_tgz
    , zulu22_macos_aarch64_tgz
    , zulu23_macos_aarch64_zip
      # , zing21_linux_tgz
    }:
      with flake-utils.lib; with system; eachSystem [ x86_64-linux aarch64-linux aarch64-darwin ] (system:
      let
        sources = with builtins; (fromJSON (readFile ./flake.lock)).nodes;
        pkgs = nixpkgs.legacyPackages.${system};
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

        openjdk_23 = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk23;
          version = "23";
          jdk = zulu_22_linux;
        };
        openjdk_23_debug = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk23;
          version = "23";
          jdk = zulu_22_linux;
          debugSymbols = true;
        };
        openjdk_23_fastdebug = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk23;
          version = "23";
          jdk = zulu_22_linux;
          debug = true;
        };

        openjdk_latest = import ./build/openjdk.nix {
          inherit pkgs nixpkgs;
          src = jdk;
          version = "latest";
          jdk = zulu_22_linux;
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
          inherit pkgs jdk_22;
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

        zulu_22_linux = import ./build/zulu.nix {
          inherit pkgs;
          src = if isAarch then zulu22_linux_aarch64_tgz else zulu22_linux_x64_tgz;
          version = "22.0.0";
        };
        zulu_22_macos = import ./build/zulu.nix {
          inherit pkgs;
          src = zulu22_macos_aarch64_tgz;
          version = "22.0.0";
        };

        zulu_23_macos = import ./build/zulu.nix {
          inherit pkgs;
          src = zulu23_macos_aarch64_zip;
          version = "23.0.0";
        };

        # zing_21 = import ./build/zing.nix {
        #   inherit pkgs;
        #   src = zing17_linux_tgz;
        #   version = "17.0.0";
        # };

        jdk_21 = if pkgs.stdenv.isLinux then openjdk_21 else pkgs.zulu21;
        jdk_22 = if pkgs.stdenv.isLinux then zulu_22_linux else zulu_22_macos;
        jdk_23 = if pkgs.stdenv.isLinux then openjdk_23 else zulu_23_macos;

        jdk = openjdk_23;

        derivation = {
          inherit openjdk_21 openjdk_21_debug openjdk_21_fastdebug
            openjdk_23 openjdk_23_debug openjdk_23_fastdebug
            openjdk_latest
            # openjdk-loom openjdk-panama openjdk-valhalla
            jtreg jextract jmc jitwatch visualvm
            async-profiler jattach
            # jprofiler yourkit
            jdk_21 jdk_22 jdk_23
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
