{ mkShell, gdb, jdk, ... }:

mkShell {
  name = "jdk-env";
  nativeBuildInputs = [ jdk patchelf ];
  buildInputs = [
    # openjdk_17
    # openjdk_18
    # openjdk-loom
    # openjdk-panama
    # openjdk-valhalla
    # zing_17
    # jdk_17
  ];
}
