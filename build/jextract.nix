{ pkgs, openjdk_21 ? null, openjdk_22 ? null, jtreg, src, check ? false }:

with pkgs;

let
  llvm_home = llvmPackages_15.libclang.lib;
  jdkPrefix = if openjdk_22 != null then "-Pjdk22_home=${openjdk_22.home}" else "-Pjdk20_home=${openjdk_21.home}";
  buildGradleCmd = cmd: "gradle --no-daemon ${jdkPrefix} -Pllvm_home=${llvm_home} ${cmd}";
  makePackage = args: stdenv.mkDerivation ({
    inherit src;
    buildInputs = [ cmake gradle ];
    dontUseCmakeConfigure = true;
  } // args);
  deps = makePackage {
    name = "deps";

    buildPhase = ''
      export GRADLE_USER_HOME=$(mktemp -d)
      ${buildGradleCmd "-Pjtreg_home=${jtreg} jtreg"} || true
    '';

    installPhase = ''
      find $GRADLE_USER_HOME -type f -regex '.*/modules.*\.\(jar\|pom\)' \
        | ${perl}/bin/perl -pe 's#(.*/([^/]+)/([^/]+)/([^/]+)/[0-9a-f]{30,40}/([^/\s]+))$# ($x = $2) =~ tr|\.|/|; "install -Dm444 $1 \$out/$x/$3/$4/$5" #e' \
        | sh
      rm -rf $out/tmp
    '';

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = lib.fakeSha256;
    # outputHash = "sha256-dV7/U5GpFxhI13smZ587C6cVE4FRNPY0zexZkYK4Yq1=";
  };
in
makePackage {
  name = "jextract";

  buildPhase = buildGradleCmd "verify";

  doInstallCheck = check;
  installCheckPhase = lib.optionalString check ''
    substituteInPlace build.gradle --replace 'mavenCentral()' 'mavenLocal(); maven { url uri("${deps}") }'

    ${buildGradleCmd "-Pjtreg_home=${jtreg} --offline jtreg"}
  '';

  installPhase = ''
    cp -r build/jextract $out
    runHook postInstall
  '';

  postInstall = ''
    sed -e 's;DIR=`dirname $0`;DIR=`dirname $(readlink -f -- $0)`;g' \
      -i $out/bin/jextract
  '';
}
