{ pkgs, jdk, src }:

with pkgs;

let
  ext = stdenv.hostPlatform.extensions.sharedLibrary;
  self = stdenv.mkDerivation rec {
    inherit src;
    name = "async-profiler";

    buildInputs = [ jdk ];

    installPhase = ''
      cp -r build $out
      ln -s $out/bin/asprof $out/bin/async-profiler
    '';

    passthru.libasyncProfiler = "${self}/libasyncProfiler${ext}";

    enableParallelBuilding = true;
    dontStrip = true;
  };
in
self
