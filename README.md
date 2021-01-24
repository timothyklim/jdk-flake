# Install

## Global installation for NixOS

/etc/nixos/configuration.nix:

```nix
{
# ...
  nixpkgs.overlays = [
    (import
      (fetchTarball {
        url = "https://github.com/TawasalMessenger/azul-zing-flake/archive/fp.dev-3354-jdk15.0.1.tar.gz";
        sha256 = "1vqfj0diz8zvp9vscbgckgni91wc4w90m2ba7v6a5183n272vh8x";
      })).overlay
  ];
# ...
}
```
