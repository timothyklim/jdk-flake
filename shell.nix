{ mkShell, gdb, async-profiler, jdk, ... }:

mkShell {
  name = "jdk-env";
  nativeBuildInputs = [ jdk ];
  buildInputs = [
    # openjdk_17
    # openjdk_18
    # openjdk-loom
    # openjdk-panama
    # openjdk-valhalla
    # zing_17
    # jdk_17
  ];

  shellHook = ''
    java -agentpath:${async-profiler.libasyncProfiler} -version
  '';
}
