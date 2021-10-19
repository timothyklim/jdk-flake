{ mkShell, openjdk_17, openjdk_18, openjdk_18-loom, openjdk_18-panama, openjdk_18-valhalla, zulu_17, zing_15, jdk_17 }:

let
  jdk = openjdk_17;
in
mkShell {
  name = "jdk-env";
  nativeBuildInputs = [ jdk ];
  buildInputs = [
    openjdk_17
    openjdk_18
    openjdk_18-loom
    # openjdk_18-panama
    # openjdk_18-valhalla
    zing_15
    jdk_17
  ];
}
