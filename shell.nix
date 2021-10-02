{ mkShell, openjdk_16, openjdk_17, openjdk_17-loom, openjdk_17-panama, openjdk_17-valhalla, openjdk_18, zulu_17, zing_15, jdk_17 }:

let
  jdk = openjdk_17;
in
mkShell {
  name = "jdk-env";
  nativeBuildInputs = [ jdk ];
  buildInputs = [
    openjdk_16
    openjdk_17
    # openjdk_17-loom
    openjdk_17-panama
    # openjdk_17-valhalla
    openjdk_18
    zing_15
    jdk_17
  ];
}
