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
        sha256 = "15fdsk12m4fhdqr6lk65i01zkla11s2pq4ynml236q698p7x5h6q";
      })).overlay
  ];
# ...
}
```
