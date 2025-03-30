{ pkgs, jdk, src }:

with pkgs;

let
  ext = stdenv.hostPlatform.extensions.sharedLibrary;
  self = stdenv.mkDerivation rec {
    inherit src;
    name = "async-profiler";

    buildInputs = [ jdk ];

    installPhase = ''
      install -D build/bin/asprof "$out/bin/async-profiler"
      install -D build/lib/libasyncProfiler${ext} "$out/lib/libasyncProfiler${ext}"
    '';

    passthru.libasyncProfiler = "${self}/libasyncProfiler${ext}";

    enableParallelBuilding = true;
    dontStrip = true;
  };
in
self
