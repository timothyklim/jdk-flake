{ mkShell, openjdk_17, openjdk_18, openjdk_19-loom, openjdk_19-panama, openjdk_19-valhalla, zulu_17, zulu_18, zing_17, jdk_17 , jdk_18 }:

let
  jdk = jdk_18;
in
mkShell {
  name = "jdk-env";
  nativeBuildInputs = [ jdk ];
  buildInputs = [
    # openjdk_17
    # openjdk_18
    # openjdk_19-loom
    # openjdk_19-panama
    # openjdk_19-valhalla
    # zing_17
    # jdk_17
  ];
}
