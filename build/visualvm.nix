{ pkgs, src, version, jre ? pkgs.jdk21 }:

with pkgs; stdenv.mkDerivation rec {
  inherit src version;
  pname = "visualvm";

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    find . -type f -name "*.dll" -o -name "*.exe" -delete;

    substituteInPlace etc/visualvm.conf \
      --replace "#visualvm_jdkhome=" "visualvm_jdkhome=" \
      --replace "/path/to/jdk" "${jre.home}" \

    cp -r . $out

    # Create desktop item.
    mkdir -p $out/share/applications
    cp ${desktopItem}/share/applications/* $out/share/applications
  '';

  desktopItem = makeDesktopItem {
    name = "visualvm";
    exec = "visualvm";
    desktopName = "VisualVM";
    genericName = "VisualVM";
    categories = [ "Development" "Debugger" ];
  };
}
