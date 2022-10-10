{ pkgs, src, jre ? pkgs.jdk17 }:

with pkgs; stdenv.mkDerivation rec {
  inherit src;
  name = "jprofiler";

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    cp -r . $out

    wrapProgram $out/bin/jprofiler \
      --prefix PATH : ${lib.makeBinPath [ jre ]} \
      --set JAVA_HOME "${jre.home}"

    # Create desktop item.
    mkdir -p $out/share/applications
    cp ${desktopItem}/share/applications/* $out/share/applications
  '';

  desktopItem = makeDesktopItem {
    name = "jprofiler";
    exec = "jprofiler";
    desktopName = "JProfiler";
    genericName = "JProfiler";
    categories = [ "Development" "Debugger" ];
  };
}
