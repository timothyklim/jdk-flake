{ pkgs, jre ? pkgs.jdk17 }:

with pkgs; stdenv.mkDerivation rec {
  name = "jitwatch";

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ jre ];

  src = fetchurl {
    url = "https://github.com/AdoptOpenJDK/jitwatch/releases/download/1.4.7/jitwatch-ui-1.4.7-shaded-linux.jar";
    sha256 = "sha256-+Jqz7YhFRfVWx8cXVWafaGlxxDfIlcTKBWs/AS8ROdQ=";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin $out/share
    cp -a $src $out/share/jitwatch.jar
    cat >> $out/bin/run.sh << EOF
    #!${runtimeShell}
    ${jre}/bin/java -jar $out/share/jitwatch.jar "$@"
    EOF
    chmod +x $out/bin/run.sh

    makeWrapper $out/bin/run.sh $out/bin/jitwatch \
      --prefix PATH : ${lib.makeBinPath [ jre ]} \
      --set JAVA_HOME "${jre.home}"

    # Create desktop item.
    mkdir -p $out/share/applications
    cp ${desktopItem}/share/applications/* $out/share/applications
  '';

  desktopItem = makeDesktopItem {
    name = "jitwatch";
    exec = "jitwatch";
    desktopName = "JITWatch";
    genericName = "JITWatch";
    categories = [ "Development" "Debugger" ];
  };
}
