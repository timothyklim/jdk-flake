{ pkgs, nixpkgs, src, version, jdk ? pkgs.openjdk_headless, nativeDeps ? [ ], patchInstall ? false, lto ? false }:

with pkgs;

let
  inherit (stdenv.hostPlatform) isAarch;
  image = if isAarch then "linux-aarch64-server-release" else "linux-x86_64-server-release";
  archCflags = if isAarch then "-march=native -mtune=native" else "-march=westmere -mtune=haswell";
  cflags = archCflags + " -O3 -funroll-loops -fomit-frame-pointer " + lib.optionalString lto "-flto";
  x11Libs = with xorg; [ libX11 libXext libXrender libXtst libXt libXi libXrandr ];
  linuxDeps = [ alsaLib ] ++ x11Libs;
  archStdenv = if isAarch then llvmPackages_16.stdenv else gcc13Stdenv;
  self = archStdenv.mkDerivation rec {
    inherit src version;
    pname = "openjdk";

    nativeBuildInputs = [ autoconf jdk pkg-config ] ++ nativeDeps;
    buildInputs = [ bash cups file gnumake fontconfig freetype libjpeg giflib libpng which zlib unzip zip lcms2 ] ++
      lib.optionals stdenv.isLinux linuxDeps;

    SOURCE_DATE_EPOCH = 315532802;

    patches = [
      "${nixpkgs}/pkgs/development/compilers/openjdk/read-truststore-from-env-jdk10.patch"
      "${nixpkgs}/pkgs/development/compilers/openjdk/currency-date-range-jdk10.patch"
      "${nixpkgs}/pkgs/development/compilers/openjdk/increase-javadoc-heap-jdk13.patch"
      # -Wformat etc. are stricter in newer gccs, per
      # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=79677
      # so grab the work-around from
      # https://src.fedoraproject.org/rpms/java-openjdk/pull-request/24
      (fetchurl {
        url = "https://src.fedoraproject.org/rpms/java-openjdk/raw/06c001c7d87f2e9fe4fedeef2d993bcd5d7afa2a/f/rh1673833-remove_removal_of_wformat_during_test_compilation.patch";
        sha256 = "082lmc30x64x583vqq00c8y0wqih3y4r0mp1c4bqq36l22qv6b6r";
      })

      ./patches/disable_incubating_warn.patch
    ] ++ lib.optionals (lib.versionOlder version "21") [
      "${nixpkgs}/pkgs/development/compilers/openjdk/fix-java-home-jdk10.patch"
    ] ++ lib.optionals (lib.versionAtLeast version "21") [
      ./patches/fix-java-home-jdk21.patch
    ];

    prePatch = lib.optional patchInstall ''
      sed -e "s,install:,INSTALL_PREFIX=$out\ninstall:,g" -i make/Install.gmk
    '';

    postPatch = ''
      chmod +x configure
      patchShebangs --build configure
    '';

    # --with-jtreg --with-debug-level=fastdebug
    configurePhase = ''
      ./configure \
        --prefix=$out \
        --disable-warnings-as-errors \
        --enable-headless-only \
        --enable-unlimited-crypto \
        --with-boot-jdk=${jdk.home} \
        --with-debug-level=release \
        --with-extra-cflags='${cflags}' \
        --with-extra-cxxflags='${cflags}' \
        --with-giflib=system \
        --with-jvm-features=link-time-opt,zgc \
        --with-jvm-variants=server \
        --with-lcms=system \
        --with-libjpeg=system \
        --with-libpng=system \
        --with-native-debug-symbols=internal \
        --with-stdc++lib=dynamic \
        --with-toolchain-type=gcc \
        --with-version-build=0 \
        --with-version-opt=nixos \
        --with-version-pre= \
        --with-zlib=system \
      || cat config.log
    '';

    NIX_CFLAGS_COMPILE = "-Wno-error";

    buildPhase = ''
      CONF=${image} make -j images
    '';

    installPhase = ''
      mkdir -p $out/lib

      mv build/*/images/jdk $out/lib/openjdk

      # Remove some broken manpages.
      rm -rf $out/lib/openjdk/man/ja*

      # Mirror some stuff in top-level.
      mkdir -p $out/share
      ln -s $out/lib/openjdk/include $out/include
      ln -s $out/lib/openjdk/man $out/share/man
      ln -s $out/lib/openjdk/lib/src.zip $out/lib/src.zip

      # jni.h expects jni_md.h to be in the header search path.
      ln -s $out/include/linux/*_md.h $out/include/

      # Remove crap from the installation.
      rm -rf $out/lib/openjdk/demo $out/lib/openjdk/lib/{libjsound,libfontmanager}.so

      ln -s $out/lib/openjdk/bin $out/bin
    '';

    preFixup = ''
      # Propagate the setJavaClassPath setup hook so that any package
      # that depends on the JDK has $CLASSPATH set up properly.
      mkdir -p $out/nix-support
      #TODO or printWords?  cf https://github.com/NixOS/nixpkgs/pull/27427#issuecomment-317293040
      echo -n "${setJavaClassPath}" > $out/nix-support/propagated-build-inputs

      # Set JAVA_HOME automatically.
      mkdir -p $out/nix-support
      cat <<EOF > $out/nix-support/setup-hook
      if [ -z "\''${JAVA_HOME-}" ]; then export JAVA_HOME=$out/lib/openjdk; fi
      EOF
    '';

    postFixup = ''
      # Build the set of output library directories to rpath against
      LIBDIRS=""
      for output in $outputs; do
        if [ "$output" = debug ]; then continue; fi
        LIBDIRS="$(find $(eval echo \$$output) -name \*.so\* -exec dirname {} \+ | sort | uniq | tr '\n' ':'):$LIBDIRS"
      done
      # Add the local library paths to remove dependencies on the bootstrap
      for output in $outputs; do
        if [ "$output" = debug ]; then continue; fi
        OUTPUTDIR=$(eval echo \$$output)
        BINLIBS=$(find $OUTPUTDIR/bin/ -type f; find $OUTPUTDIR -name \*.so\*)
        echo "$BINLIBS" | while read i; do
          patchelf --set-rpath "$LIBDIRS:$(patchelf --print-rpath "$i")" "$i" || true
          patchelf --shrink-rpath "$i" || true
        done
      done
    '';

    disallowedReferences = [ jdk ];

    passthru = {
      architecture = "";
      home = "${self}/lib/openjdk";
    };

    preferLocalBuild = true;
  };
in
self
