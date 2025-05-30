{
  description = "JDK's flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self , nixpkgs , flake-utils }:
      with flake-utils.lib; with system; eachSystem [ x86_64-linux aarch64-linux aarch64-darwin ]
        (system:
        let
          pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
          inherit (pkgs.stdenv.hostPlatform) isAarch;

          sources = with pkgs; {
            async-profiler.default = fetchFromGitHub {
              repo = "async-profiler";
              owner = "jvm-profiling-tools";
              rev = "6979a9eff23d24db4268f842b28f153831f1a9ee";
              # sha256 = lib.fakeSha256;
              hash = "sha256-dMKy6A0mbi/YI/MbkBAeoVDnMn+ZoKi8FDas2qcEdGU=";
            };

            jdk24.default = fetchFromGitHub {
              repo = "jdk24u";
              owner = "openjdk";
              rev = "c15293d9778dc153f95ff6bdd747dee844f260f1";
              # sha256 = lib.fakeSha256;
              hash = "sha256-qQIo8P4sQ7oSNntIGzxbJmsL9FftJmVNRnvOyVDkPv4=";
            };

            jattach.default = fetchFromGitHub {
              repo = "jattach";
              owner = "jattach";
              rev = "4b0b0545418aa7b768df1832a572b2c53a4edd21";
              # sha256 = lib.fakeSha256;
              hash = "sha256-3eFoIfKJNXLg9WPhQBIsUjbIGdmmHFe9RqjYmTm8EwI=";
            };

            jextract.default = fetchFromGitHub {
              repo = "jextract";
              owner = "openjdk";
              rev = "3fe6e4ea9480aa0489407ddd215cdf2a4c9f2430";
              # sha256 = lib.fakeSha256;
              hash = "sha256-4vvjQrS+n3wv4hiEoRBaTT76EPA4hc99Z6DR2dfagVQ=";
            };

            jtreg.default = fetchFromGitHub {
              repo = "jtreg";
              owner = "openjdk";
              rev = "jtreg-7.5.1+1";
              # sha256 = lib.fakeSha256;
              hash = "sha256-1SGECdaAUvGQ5jK2eHV0WK+2Fw1BI08QO5yVs3XpiGU=";
            };

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
          zulu_24 = if pkgs.stdenv.isLinux then zulu_24_linux else zulu_24_macos;

          openjdk_24 = import ./build/openjdk.nix {
            inherit pkgs nixpkgs;
            src = sources.jdk24.default;
            version = "24";
            jdk = zulu_24;
          };
          openjdk_24_debug = import ./build/openjdk.nix {
            inherit pkgs nixpkgs;
            src = sources.jdk24.default;
            version = "24";
            jdk = zulu_24;
            debugSymbols = true;
          };
          openjdk_24_fastdebug = import ./build/openjdk.nix {
            inherit pkgs nixpkgs;
            src = sources.jdk24.default;
            version = "24";
            jdk = zulu_24;
            debug = true;
          };

          jtreg = import ./build/jtreg.nix {
            inherit pkgs;
            src = sources.jtreg.default;
          };
          jextract = import ./build/jextract.nix {
            inherit pkgs;
            jdk = zulu_24;
            src = sources.jextract.default;
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
            jdk = zulu_24;
            src = sources.async-profiler.default;
          };
          jattach = import ./build/jattach.nix {
            inherit pkgs;
            src = sources.jattach.default;
          };

          # jprofiler = import ./build/jprofiler.nix {
          #   inherit pkgs;
          #   src = jprofiler_tgz;
          # };
          # yourkit = import ./build/yourkit.nix {
          #   inherit pkgs;
          #   src = yourkit_zip;
          # };

          jdk_24 = if pkgs.stdenv.isLinux then openjdk_24 else zulu_24_macos;

          jdk = jdk_24;

          derivation = {
            inherit openjdk_24 openjdk_24_debug openjdk_24_fastdebug
              zulu_24
              jtreg jextract jmc jitwatch visualvm
              async-profiler jattach
              # jprofiler yourkit
              jdk_24 jdk
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
          inherit (self.packages.${prev.system}) openjdk_24 openjdk_24_debug openjdk_24_fastdebug
            zulu_24
            jtreg jextract jmc jitwatch visualvm
            async-profiler jattach
            # jprofiler yourkit
            jdk_24 jdk
            ;
        };
      };
}
