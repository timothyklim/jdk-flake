{ pkgs, nixpkgs, src, version, jdk ? pkgs.jdk_headless, nativeDeps ? [ ], debug ? false, debugSymbols ? false, patchInstall ? false }:

with pkgs;

let
  inherit (stdenv.hostPlatform) isAarch;
  debugLevel = if debug then "fastdebug" else "release";
  nativeDebugSymbols = if debug then "internal" else if debugSymbols then "external" else "none";
  jvmFeatures = [ "zgc" ] ++ lib.optionals (!debug) [ "link-time-opt" ];
  image = if stdenv.isDarwin then "macosx-aarch64-server-${debugLevel}" else if isAarch then "linux-aarch64-server-${debugLevel}" else "linux-x86_64-server-${debugLevel}";
  archCflags = if isAarch then "-march=native -mtune=native" else "-march=westmere -mtune=haswell";
  cflags = "${archCflags} -O3 -funroll-loops";
  x11Libs = with xorg; [ libX11 libXext libXrender libXtst libXt libXi libXrandr ];
  linuxDeps = [ alsa-lib ] ++ x11Libs;

  darwinConfigureParams = if stdenv.isDarwin then "--with-xcode-path=${darwin.xcode_15_1} --with-extra-path=${darwin.xcode_15_1}/Contents/Developer/usr/bin --with-libjpeg=bundled --with-giflib=bundled --with-lcms=bundled" else "";
  darwinDeps = [ patchelf darwin.xcode_15_1 darwin.bootstrap_cmds darwin.xattr ];
  bootJdk = jdk.home;

  self = with llvmPackages_19; libcxxStdenv.mkDerivation rec {
    inherit src version;
    pname = "openjdk";

    libs = [ libjpeg giflib libpng ];
    libsPath = lib.makeLibraryPath libs;

    nativeBuildInputs = [ autoconf jdk pkg-config ] ++
      nativeDeps ++
      lib.optionals stdenv.isDarwin darwinDeps;
    runtimeDependencies = map lib.getLib libs;
    buildInputs = [ libcxx bash cups file gnumake fontconfig freetype which zlib unzip zip lcms2 lld ] ++
      libs ++
      lib.optionals stdenv.isLinux linuxDeps ++
      lib.optionals stdenv.isDarwin darwinDeps;

    SOURCE_DATE_EPOCH = 315532802;

    patches = [
      ./patches/disable_incubating_warn.patch
    ] ++ lib.optionals (lib.versionOlder version "21") [
      "${nixpkgs}/pkgs/development/compilers/openjdk/fix-java-home-jdk10.patch"
    ] ++ lib.optionals (lib.versionAtLeast version "21" && lib.versionOlder "24" version) [
      ./patches/fix-java-home-jdk21.patch
    ] ++ lib.optionals (lib.versionAtLeast version "24") [
      ./patches/fix-java-home-jdk24.patch
      ./patches/read-truststore-from-env-jdk24.patch
    ] ++ lib.optionals (lib.versionOlder "23" version && lib.versionOlder "24" version) [
      "${nixpkgs}/pkgs/development/compilers/openjdk/11/patches/read-truststore-from-env-jdk10.patch"
      "${nixpkgs}/pkgs/development/compilers/openjdk/11/patches/currency-date-range-jdk10.patch"
      "${nixpkgs}/pkgs/development/compilers/openjdk/17/patches/increase-javadoc-heap-jdk13.patch"
      # -Wformat etc. are stricter in newer gccs, per
      # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=79677
      # so grab the work-around from
      # https://src.fedoraproject.org/rpms/java-openjdk/pull-request/24
      (fetchurl {
        url = "https://src.fedoraproject.org/rpms/java-openjdk/raw/06c001c7d87f2e9fe4fedeef2d993bcd5d7afa2a/f/rh1673833-remove_removal_of_wformat_during_test_compilation.patch";
        sha256 = "082lmc30x64x583vqq00c8y0wqih3y4r0mp1c4bqq36l22qv6b6r";
      })
    ];

    prePatch = lib.optional patchInstall ''
      sed -e "s,install:,INSTALL_PREFIX=$out\ninstall:,g" -i make/Install.gmk
    '';

    postPatch = ''
      chmod +x configure
      patchShebangs --build configure
    '';

    # --with-jtreg
    configurePhase = ''
      export NIX_CFLAGS_COMPILE="-isystem ${lib.getDev libcxx}/include/c++/v1 $NIX_CFLAGS_COMPILE"

      ./configure \
        --prefix=$out \
        --disable-warnings-as-errors \
        --enable-headless-only \
        --enable-unlimited-crypto \
        --enable-reproducible-build \
        --with-boot-jdk=${bootJdk} \
        --with-debug-level=${debugLevel} \
        --with-extra-cflags='${cflags}' \
        --with-extra-cxxflags='${cflags}' \
        --with-giflib=system \
        --with-jvm-features=${lib.concatStringsSep "," jvmFeatures} \
        --with-jvm-variants=server \
        --with-lcms=system \
        --with-libjpeg=system \
        --with-libpng=system \
        --with-native-debug-symbols=${nativeDebugSymbols} \
        --with-stdc++lib=static \
        --with-toolchain-type=clang \
        --with-version-build=0 \
        --with-version-opt=nixos \
        --with-version-pre= \
        --with-zlib=system \
        ${darwinConfigureParams} \
      || cat config.log
    '';

    NIX_CFLAGS_COMPILE = "-Wno-error";

    buildPhase = ''
      export LD_LIBRARY_PATH="${lib.makeLibraryPath [ zlib ]}:$LD_LIBRARY_PATH"
      CONF=${image} make images || cat /build/source/build/${image}/make-support/failure-logs
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

      ln -s ${lib.getLib zlib}/lib/libz.so.1 $out/lib/openjdk/lib/
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
          patchelf --set-rpath "${libsPath}:$LIBDIRS:$(patchelf --print-rpath "$i")" "$i" || true
          patchelf --shrink-rpath "$i" || true
        done
      done
    '';

    disallowedReferences = [ jdk ];

    passthru = {
      architecture = "";
      home = "${self}/lib/openjdk";
    };

    dontStrip = true;
    preferLocalBuild = true;
  };
in
self
