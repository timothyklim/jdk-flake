# Install

## Global installation for NixOS

/etc/nixos/configuration.nix:

```nix
{
# ...
  nixpkgs.overlays = [
    (import
      (fetchTarball {
        url = "https://github.com/TawasalMessenger/jdk-flake/archive/zing-jdk15.0.1-fp.dev-3370.tar.gz";
        sha256 = "0z10zfd16j78fk131ykyv3sdpj6srzj7h9s5269f5h7762jm9a70";
      })).overlay
  ];
# ...
}
```
