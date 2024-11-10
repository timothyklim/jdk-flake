{ pkgs, src, version, jre ? pkgs.jdk21 }:

with pkgs; stdenv.mkDerivation rec {
  inherit src version;
  pname = "zmc";

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];
  buildInputs = [ jre ];

  installPhase = ''
    cp -r ./'Azul Mission Control' $out

    mkdir -p $out/bin
    makeWrapper $out/zmc $out/bin/zmc \
      --prefix PATH : ${lib.makeBinPath [ jre ]} \
      --set JAVA_HOME "${jre.home}"

    # Create desktop item.
    mkdir -p $out/share/applications
    cp ${desktopItem}/share/applications/* $out/share/applications
    mkdir -p $out/share/pixmaps
    ln -s $out/icon.xpm $out/share/pixmaps/zmc.xpm
  '';

  desktopItem = makeDesktopItem {
    name = "zmc";
    exec = "zmc";
    desktopName = "JMC";
    genericName = "JDK Mission Control";
    categories = [ "Development" "Debugger" ];
  };
}
