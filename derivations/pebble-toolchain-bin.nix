{
  stdenv,
  lib,
  fetchzip,
  autoPatchelfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pebble-toolchain-bin";
  version = "4.9.169";

  src =
    ({
      x86_64-linux = fetchzip {
        url = "https://sdk.repebble.com/releases/${finalAttrs.version}/toolchain-linux-x86_64.tar.gz";
        hash = "sha256-tz1DvYe9I262BfZsZNauII893yQf5QHlvQ3TpWG17vQ=";
        stripRoot = false;
      };
      x86_64-darwin = fetchzip {
        url = "https://sdk.repebble.com/releases/${finalAttrs.version}/toolchain-mac-x86_64.tar.gz";
        hash = "sha256-1672hlLCs2cLaZPnTt0J92MgmcIA1OQMvTeVKWTuTUs=";
        stripRoot = false;
      };
      aarch64-darwin = fetchzip {
        url = "https://sdk.repebble.com/releases/${finalAttrs.version}/toolchain-mac-arm64.tar.gz";
        hash = "sha256-Qb+yqbXbWUOi188eh3jZ84rhqzY9MO/B2FawTQKAYJ0=";
        stripRoot = false;
      };
    }).${stdenv.hostPlatform.system};

  nativeBuildInputs = lib.optional stdenv.hostPlatform.isLinux autoPatchelfHook;

  installPhase = ''
    mv toolchain-*/arm-none-eabi $out
  '';

  dontStrip = true;
})
