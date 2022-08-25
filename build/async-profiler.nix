{ pkgs, jdk, src, version }:

let
  self = with pkgs; stdenv.mkDerivation rec {
    inherit src version;
    pname = "async-profiler";

    buildInputs = [ jdk ];

    patchPhase = ''
      patchShebangs .
      substituteInPlace Makefile \
        --replace '/bin/ls' "${coreutils}/bin/ls"
    '';

    installPhase = ''
      cp -r build $out
    '';

    passthru.libasyncProfiler = "${self}/libasyncProfiler.so";

    dontStrip = true;
  };
in
self
