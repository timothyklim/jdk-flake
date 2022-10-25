{ pkgs, src, jre ? pkgs.jdk17 }:

with pkgs;

let
  arch =
    if stdenv.hostPlatform.system == "x86_64-linux" then "linux-x86-64"
    else throw "Unsupported architecture";
  self = stdenv.mkDerivation rec {
    inherit src;
    name = "yourkit";

    nativeBuildInputs = [ makeWrapper ];

    installPhase = ''
      find . -type f -name "*.dll" -o -name "*.exe" -delete;

      cp -r . $out

      makeWrapper $out/bin/profiler.sh $out/bin/yourkit \
        --prefix PATH : ${lib.makeBinPath [ jre ]} \
        --set YJP_JAVA_HOME "${jre.home}"

      # Create desktop item.
      mkdir -p $out/share/applications
      cp ${desktopItem}/share/applications/* $out/share/applications
      mkdir -p $out/share/pixmaps
      ln -s $out/bin/profiler.ico $out/share/pixmaps/yourkit.ico
    '';

    passthru.libyjpagent = "${self}/bin/${arch}.so";

    desktopItem = makeDesktopItem {
      name = "yourkit";
      exec = "yourkit";
      desktopName = "YourKit";
      genericName = "YourKit";
      categories = [ "Development" "Debugger" ];
    };
  };
in
self
