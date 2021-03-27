{ mkShell, zing_15, openjdk_15, openjdk_16, openjdk_17, openjdk_17-loom, openjdk_17-valhalla }:

let
  jdk = zing_15;
in
mkShell {
  name = "jdk-env";

  nativeBuildInputs = [ jdk ];
  buildInputs = [
    zing_15
    openjdk_15
    openjdk_16
    openjdk_17
    openjdk_17-loom
    # openjdk_17-valhalla
  ];

  shellHook = ''
    export JAVA_HOME=${jdk.home}
    export JAVA_INCLUDE_PATH=${jdk.home}/include
    export JNI_INCLUDE_DIRS=${jdk.home}/include
  '';
}
