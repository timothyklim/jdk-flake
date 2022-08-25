{ pkgs, src, version }:

with pkgs;

let
  jre = jdk17;
in
stdenv.mkDerivation rec {
  inherit src version;
  pname = "jmc";

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];
  buildInputs = [ jre ];

  installPhase = ''
    cp -r ./'JDK Mission Control' $out

    mkdir -p $out/bin
    makeWrapper $out/jmc $out/bin/jmc \
      --prefix PATH : ${lib.makeBinPath [ jre ]} \
      --set JAVA_HOME "${jre.home}"
  '';
}
