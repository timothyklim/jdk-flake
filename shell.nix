{ mkShell, zing }:

mkShell {
  name = "azul-zing-env";

  buildInputs = [ zing ];

  shellHook = ''
    export JAVA_HOME=${zing.home}
    export JAVA_INCLUDE_PATH=${zing.home}/include
    export JNI_INCLUDE_DIRS=${zing.home}/include
  '';
}
