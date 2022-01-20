{ pkgs, src, version }:

with pkgs;
with pkgs.lib;
let
  self = stdenv.mkDerivation rec {
    inherit src version;

    pname = "zing";

    buildInputs = [ makeWrapper ];

    installPhase = ''
      mkdir -p $out
      cp -r ./* "$out/"

      rpath=$rpath''${rpath:+:}$out/lib/jli
      rpath=$rpath''${rpath:+:}$out/lib/server
      rpath=$rpath''${rpath:+:}$out/lib
      rpath=$rpath''${rpath:+:}$out/etc/zing/lib
      rpath=$rpath''${rpath:+:}$out/etc/orca/lib
      rpath=$rpath''${rpath:+:}$out/etc/rni
      rpath=$rpath''${rpath:+:}$out/etc/libc++

      # set all the dynamic linkers
      find $out -type f -perm -0100 \
          -exec patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          --set-rpath "$rpath" {} \;

      find $out -name "*.so" -exec patchelf --set-rpath "$rpath" --force-rpath {} \;

      mkdir -p $out/nix-support
      printWords ${setJavaClassPath} > $out/nix-support/propagated-build-inputs

      # Set JAVA_HOME automatically.
      cat <<EOF >> $out/nix-support/setup-hook
      if [ -z "\''${JAVA_HOME-}" ]; then export JAVA_HOME=$out; fi
      EOF
    '';

    rpath = strings.makeLibraryPath [
      stdenv.cc.libc
      stdenv.cc.cc.lib
      glib
      linux-pam
      libxml2
      libxslt
      libGL
      xorg.libXxf86vm
      alsaLib
      fontconfig
      freetype
      pango
      gtk2
      cairo
      gdk-pixbuf
      atk
      zlib
    ];

    passthru.home = self;

    dontStrip = true;
    dontPatchELF = true;
  };
in
self
