{ pkgs, src }:

with pkgs; stdenv.mkDerivation rec {
  inherit src;
  name = "jattach";

  preBuild = (lib.optionalString stdenv.isDarwin ''
    substituteInPlace Makefile \
      --replace "CFLAGS ?= -O3 -arch x86_64 -arch arm64 -mmacos-version-min=10.12" "CFLAGS ?= -O3 -arch arm64 -mmacos-version-min=10.12"
  '');

  installPhase = ''
    mkdir -p $out/bin
    cp -r build/jattach $out/bin/
  '';

  dontStrip = true;
}
