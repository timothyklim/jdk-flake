{ mkShell, zing_15, openjdk_16, openjdk_17, openjdk_17-loom, /*openjdk_17-panama,*/ openjdk_17-valhalla, openjdk_18 }:

let
  jdk = openjdk_17;
in
mkShell {
  name = "jdk-env";
  nativeBuildInputs = [ jdk ];
  buildInputs = [
    zing_15
    openjdk_16
    openjdk_17
    # openjdk_17-loom
    # openjdk_17-panama
    # openjdk_17-valhalla
    openjdk_18
  ];
}
