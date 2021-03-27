{ pkgs, src, version, patchInstall ? false }:

with pkgs;

let
  image = "linux-x86_64-server-release";
  x11Libs = with xorg; [ libX11 libXext libXrender libXtst libXt libXi libXrandr ];
  self = gcc10Stdenv.mkDerivation rec {
    inherit src version;
    pname = "openjdk";

    nativeBuildInputs = [ autoconf jdk15 pkg-config ];
    buildInputs = [ alsaLib bash cups file gnumake fontconfig freetype which zlib unzip zip ] ++ x11Libs;

    prePatch = lib.optional patchInstall ''
      sed -e "s,install:,INSTALL_PREFIX=$out\ninstall:,g" -i make/Install.gmk
    '';

    postPatch = ''
      substituteInPlace ./configure --replace "/bin/bash" "${bash}/bin/bash"
      chmod +x ./configure
    '';

    # --with-jtreg --with-debug-level=fastdebug
    configurePhase = ''
      ./configure \
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
      make install
    '';

    passthru.home = self;

    preferLocalBuild = true;
  };
in
self
