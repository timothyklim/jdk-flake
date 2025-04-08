{ pkgs, src }:

with pkgs;

let
  jdk = jdk_headless;
  deps = stdenv.mkDerivation {
    inherit src;

    name = "deps";

    nativeBuildInputs = [ stripJavaArchivesHook ];
    buildInputs = [
      bash
      curl
      wget
      which
      unzip
    ];

    patches = [
      ./patches/jtreg.patch
    ];

    buildPhase = ''
      WGET_OPTIONS="-v --no-check-certificate" bash make/build.sh \
        --jdk ${jdk.home} \
        --skip-make
    '';

    installPhase = ''
      mkdir -p $out

      cp -r dist/* $out/
    '';

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    # outputHash = lib.fakeSha256;
    outputHash = "sha256-rySJwL34gOP+tuH43Ig43VFpAYW/Rt3syAhsJif0aXg=";
  };
in
stdenv.mkDerivation rec {
  inherit src;

  name = "jtreg";

  buildInputs = [ bash coreutils hostname which gnused git perl zip gawk findutils gnugrep pandoc ];

  JDKHOME = jdk.home;

  patchPhase = ''
    patchShebangs .
    substituteInPlace make/Defs.gmk \
      --replace '/bin/echo' "${coreutils}/bin/echo" \
      --replace '/bin/date' "${coreutils}/bin/date" \
      --replace '/bin/mkdir' "${coreutils}/bin/mkdir" \
      --replace '/bin/rm' "${coreutils}/bin/rm" \
      --replace '/bin/cp' "${coreutils}/bin/cp" \
      --replace '/bin/cat' "${coreutils}/bin/cat" \
      --replace '/bin/chmod' "${coreutils}/bin/chmod" \
      --replace '/usr/bin/diff' "${coreutils}/bin/diff" \
      --replace '/bin/ln' "${coreutils}/bin/ln" \
      --replace '/bin/ls' "${coreutils}/bin/ls" \
      --replace '/bin/mv' "${coreutils}/bin/mv" \
      --replace '/usr/bin/printf' "${coreutils}/bin/printf" \
      --replace '/usr/bin/sort' "${coreutils}/bin/sort" \
      --replace '/usr/bin/test' "${coreutils}/bin/test" \
      --replace '/usr/bin/touch' "${coreutils}/bin/touch" \
      --replace '/usr/bin/perl' "${perl}/bin/perl" \
      --replace '/usr/bin/awk' "${gawk}/bin/awk" \
      --replace '/usr/bin/find' "${findutils}/bin/find" \
      --replace '/usr/bin/grep' "${gnugrep}/bin/grep" \
      --replace '/usr/bin/pandoc' "${pandoc}/bin/pandoc" \
      --replace '/usr/bin/sed' "${gnused}/bin/sed" \
      --replace '/bin/sh' "${bash}/bin/sh" \
      --replace '/usr/bin/zip' "${zip}/bin/zip"
  '';

  postPatch = ''
    cp -r ${deps} build/
  '';

  buildPhase = ''
    JUNIT_JARS=""
    for f in $(ls ${deps}/junit/)
    do
      JUNIT_JARS="$JUNIT_JARS ${deps}/junit/$f"
    done

    TESTNG_JARS=""
    for f in $(ls ${deps}/testng/)
    do
      TESTNG_JARS="$TESTNG_JARS ${deps}/testng/$f"
    done

    mkdir -p build

    make -C make \
      BUILDDIR=$(pwd)/build \
      ASMTOOLS_JAR="${deps}/asmtools.jar" \
      JAVATEST_JAR="${deps}/javatest.jar" \
      JUNIT_JARS="$JUNIT_JARS" \
      TESTNG_JARS="$TESTNG_JARS"
  '';

  installPhase = ''
    cp -r build/images/jtreg $out
  '';
}
