{ pkgs, jdk, src }:

let
  self = with pkgs; stdenv.mkDerivation rec {
    inherit src;
    name = "async-profiler";

    buildInputs = [ jdk ];

    patchPhase = ''
      patchShebangs .
      substituteInPlace Makefile \
        --replace '/bin/ls' "${coreutils}/bin/ls"
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp profiler.sh $out/
      cp -r build $out/
      ln -s $out/profiler.sh $out/bin/async-profiler
    '';

    passthru.libasyncProfiler = "${self}/libasyncProfiler.so";

    enableParallelBuilding = true;
    dontStrip = true;
  };
in
self
