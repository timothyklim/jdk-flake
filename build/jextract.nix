{ pkgs, jdk_22, src }:

with pkgs; stdenv.mkDerivation {
  inherit src;

  name = "jextract";

  buildInputs = [ cmake gradle_7 ];
  dontUseCmakeConfigure = true;

  buildPhase = ''
    export GRADLE_USER_HOME=$(mktemp -d)
    gradle --no-daemon -Pjdk22_home=${jdk_22.home} -Pllvm_home=${llvmPackages_13.libclang.lib} build
  '';

  installPhase = ''
    cp -r build/jextract $out
    runHook postInstall

    sed -e 's;ROOT=`dirname $0`;ROOT=`dirname $(readlink -f -- $0)`;g' \
      -i $out/bin/jextract
  '' + lib.optionalString stdenv.isLinux ''
    patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${lib.makeLibraryPath [ zlib ]}:$out/runtime/lib" $out/runtime/bin/java
  '';
}
