{ pkgs, src, version, patch ? false }:

with pkgs;

let
  x11Libs = with xorg; [ libX11 libXext libXrender libXtst libXt libXi libXrandr ];
  image = "linux-x86_64-server-release";
  self = gcc10Stdenv.mkDerivation rec {
    inherit src version;
    pname = "openjdk";

    nativeBuildInputs = [ autoconf bash file gnumake jdk15 pkgconfig unzip zip ];
    buildInputs = [ alsaLib cups fontconfig freetype zlib ] ++ x11Libs;

    prePatch = lib.optional patch ''
      sed -e "s,install:,INSTALL_PREFIX=$out\ninstall:,g" -i make/Install.gmk
    '';

    # --with-jtreg --with-debug-level=fastdebug
    configurePhase = ''
      bash ./configure \
        --prefix=$out \
        --disable-warnings-as-errors \
        --with-debug-level=release \
        --with-toolchain-type=gcc \
        --with-jvm-variants=server \
        --with-jvm-features=link-time-opt \
        --with-extra-cflags='-O3 -march=native -mtune=native -funroll-loops -fomit-frame-pointer' \
        --with-extra-cxxflags='-O3 -march=native -mtune=native -funroll-loops -fomit-frame-pointer'
    '';

    buildPhase = ''
      CONF=${image} make images
    '';

    installPhase = ''
      mkdir $out

      make install
    '';

    passthru.home = self;
  };
in
self
