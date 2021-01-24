# Install

## Global installation for NixOS

/etc/nixos/configuration.nix:

```nix
{
# ...
  nixpkgs.overlays = [
    (import
      (fetchTarball {
        url = "https://github.com/TawasalMessenger/azul-zing-flake/archive/a55021c429fc36f5816ea539eb57f147330db63a.tar.gz";
        sha256 = "0xf1wf7y8k54dxxc5rlv0d4w9vrjwdnmsgpw0lxpd2kcy8v82sx3";
      })).overlay
  ];
# ...
}
```
