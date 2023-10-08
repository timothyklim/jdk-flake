{ pkgs, src }:

with pkgs; stdenv.mkDerivation rec {
  inherit src;
  name = "jattach";

  installPhase = ''
    mkdir -p $out/bin
    cp -r build/jattach $out/bin/
  '';

  dontStrip = true;
}
