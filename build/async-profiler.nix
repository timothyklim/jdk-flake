{ pkgs, jdk, src }:

with pkgs;

let
  libSuffix = if stdenv.isDarwin then "dylib" else "so";
  self = stdenv.mkDerivation rec {
    inherit src;
    name = "async-profiler";

    buildInputs = [ jdk ];

    patchPhase = ''
      patchShebangs .
      substituteInPlace Makefile \
        --replace '/bin/ls' "${coreutils}/bin/ls"
    '';

    installPhase = ''
      cp -r build $out
      ln -s $out/bin/asprof $out/bin/async-profiler
    '';

    passthru.libasyncProfiler = "${self}/libasyncProfiler.${libSuffix}";

    enableParallelBuilding = true;
    dontStrip = true;
  };
in
self
