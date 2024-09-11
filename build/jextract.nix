{ pkgs, jdk_22, src }:

with pkgs;

let
  libPath = lib.makeLibraryPath [ zlib ];
in
stdenv.mkDerivation {
  inherit src;

  name = "jextract";

  buildInputs = [ cmake gradle_7 ];
  dontUseCmakeConfigure = true;

  buildPhase = ''
    gradle --no-daemon -Pjdk22_home=${jdk_22.home} -Pllvm_home=${llvmPackages_13.libclang.lib} build
  '';

  installPhase = ''
    cp -r build/jextract $out
    runHook postInstall

    patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath}:$out/runtime/lib" $out/runtime/bin/java
  '';
}
