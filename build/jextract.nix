{ pkgs, openjdk_19, jtreg, src, doInstallCheck ? false }:

with pkgs;

let
  jdk_home = openjdk_19.home;
  llvm_home = llvmPackages_14.libclang.lib;
  buildGradleCmd = cmd: ''
    gradle --no-daemon \
      -Pjdk19_home=${jdk_home} \
      -Pllvm_home=${llvm_home} \
      ${cmd}
  '';
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
  inherit doInstallCheck;

  name = "jextract";

  buildPhase = buildGradleCmd "verify";

  installCheckPhase = lib.optionalString doInstallCheck ''
    substituteInPlace build.gradle --replace 'mavenCentral()' 'mavenLocal(); maven { url uri("${deps}") }'

    ${buildGradleCmd "-Pjtreg_home=${jtreg} --offline jtreg"}
  '';

  installPhase = ''
    cp -r build/jextract $out
  '';
}
