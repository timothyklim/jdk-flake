{ mkShell, zing, openjdk_16, openjdk_17, openjdk_17-loom, openjdk_17-valhalla }:

let
  jdk = openjdk_17-loom; # zing;
in
mkShell {
  name = "jdk-env";

  buildInputs = [ jdk ];

  shellHook = ''
    export JAVA_HOME=${jdk.home}
    export JAVA_INCLUDE_PATH=${jdk.home}/include
    export JNI_INCLUDE_DIRS=${jdk.home}/include
  '';
}
