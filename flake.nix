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

    async-profiler-src = {
      url = "github:jvm-profiling-tools/async-profiler";
      flake = false;
    };
    jattach-src = {
      url = "github:jattach/jattach";
      flake = false;
    };
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
    , async-profiler-src
    , jattach-src
    }:
      with flake-utils.lib; with system; eachSystem [ x86_64-linux aarch64-linux aarch64-darwin ]
        (system:
        let
          pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
          inherit (pkgs.stdenv.hostPlatform) isAarch;

          sources = with pkgs; {
            jmc = rec {
              version = "9.1.0.25";
              x86_64-linux = fetchurl {
                url = "https://cdn.azul.com/zmc/bin/zmc${version}-ca-linux_x64.tar.gz";
                # sha256 = lib.fakeSha256;
                hash = "sha256-oUCFiN9Pb4Lkdwt7aO2/nojSMZNqWd4z+9lv2PzzKow=";
              };
            };

            visualvm = rec {
              version = "2.1.10";
              default = fetchurl {
                url = "https://github.com/oracle/visualvm/releases/download/${version}/visualvm_2110.zip";
                # sha256 = lib.fakeSha256;
                hash = "sha256-h4UK+emHPGkMu3YFZifnPfv9Hh2VJ5qQMXIqhaw22Zk=";
              };
            };

            zulu_24 = rec {
              version = "24.0.0";
              x86_64-linux = fetchurl {
                url = "https://cdn.azul.com/zulu/bin/zulu24.28.83-ca-jdk${version}-linux_x64.tar.gz";
                # sha256 = lib.fakeSha256;
                hash = "sha256-Kf6gF8A8ZFIhujEgjlENeuSPVzW6QWnVZcRst35/ZvI=";
              };
              aarch64-darwin = fetchurl {
                url = "https://cdn.azul.com/zulu/bin/zulu24.28.83-ca-jdk${version}-macosx_aarch64.tar.gz";
                # sha256 = lib.fakeSha256;
                hash = "sha256-7yXLOJCK0RZ8V1vsexOGxGR9NAwi/pCl95BlO8E8nGU=";
              };
            };
          };

          # jprofiler_tgz = {
          #   url = "https://download.ej-technologies.com/jprofiler/jprofiler_linux_14_0.tar.gz";
          #   flake = false;
          # };
          # yourkit_zip = {
          #   url = "https://download.yourkit.com/yjp/2023.9/YourKit-JavaProfiler-2023.9-b107-arm64.zip";
          #   flake = false;
          # };

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
            inherit (sources.jmc) version;
            src = sources.jmc.${system};
          };
          jitwatch = import ./build/jitwatch.nix { inherit pkgs; };
          visualvm = import ./build/visualvm.nix {
            inherit pkgs;
            inherit (sources.visualvm) version;
            src = sources.visualvm.default;
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
            inherit (sources.zulu_24) version;
            src = sources.zulu_24.${system};
          };
          zulu_24_macos = import ./build/zulu.nix {
            inherit pkgs;
            inherit (sources.zulu_24) version;
            src = sources.zulu_24.${system};
          };

          jdk_21 = if pkgs.stdenv.isLinux then openjdk_21 else pkgs.zulu21;
          jdk_24 = if pkgs.stdenv.isLinux then openjdk_24 else zulu_24_macos;

          zulu_24 = if pkgs.stdenv.isLinux then zulu_24_linux else zulu_24_macos;

          jdk = jdk_24;

          derivation = {
            inherit openjdk_21 openjdk_21_debug openjdk_21_fastdebug
              openjdk_24 openjdk_24_debug openjdk_24_fastdebug
              openjdk_latest
              zulu_24
              # openjdk-loom openjdk-panama openjdk-valhalla
              jtreg jextract jmc jitwatch visualvm
              async-profiler jattach
              # jprofiler yourkit
              jdk_21 jdk_24 jdk
              ;
          };
        in
        rec
        {
          packages = derivation;
          devShells.default = pkgs.callPackage ./shell.nix derivation;
          checks.hashes = pkgs.runCommand "hashes" { } ''
            mkdir -p $out

            ${nixpkgs.lib.concatStringsSep "\n" (
              builtins.concatLists (
                nixpkgs.lib.mapAttrsToList (name: attr:
                  nixpkgs.lib.mapAttrsToList (platform: src:
                    if builtins.isAttrs src && src ? type && src.type == "derivation"
                    then "echo '${name}.${platform} hash verified: ${src}' >> $out/success"
                    else ""
                  ) attr
                ) sources
              )
            )}
          '';
          formatter = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
        }) // {
        nixosModules.default = {
          nixpkgs.overlays = [ overlays.default ];
        };
        overlays.default = final: prev: {
          inherit (self.packages.${prev.system}) openjdk_21 openjdk_21_debug openjdk_21_fastdebug
            openjdk_24 openjdk_24_debug openjdk_24_fastdebug
            openjdk_latest
            zulu_24
            # openjdk-loom openjdk-panama openjdk-valhalla
            jtreg jextract jmc jitwatch visualvm
            async-profiler jattach
            # jprofiler yourkit
            jdk_21 jdk_24 jdk
            ;
        };
      };
}
