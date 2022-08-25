{ pkgs, src, version, jre ? pkgs.jdk17 }:

with pkgs; stdenv.mkDerivation rec {
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

    # Create desktop item.
    mkdir -p $out/share/applications
    cp ${desktopItem}/share/applications/* $out/share/applications
    mkdir -p $out/share/pixmaps
    ln -s $out/icon.xpm $out/share/pixmaps/jmc.xpm
  '';

  desktopItem = makeDesktopItem {
    name = "jmc";
    exec = "jmc";
    desktopName = "JMC";
    genericName = "JDK Mission Control";
    categories = [ "Development" "Debugger" ];
  };
}
