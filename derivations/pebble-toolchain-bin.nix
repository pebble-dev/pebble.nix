{
  stdenv,
  lib,
  fetchzip,
  autoPatchelfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pebble-toolchain-bin";
  version = "4.33.1";

  src =
    ({
      x86_64-linux = fetchzip {
        url = "https://sdk.repebble.com/releases/${finalAttrs.version}/toolchain-linux-x86_64.tar.gz";
        hash = "sha256-lJgmri289HETYfJkwywCdJ1V/yD8WSItLq7Apvc0j1k=";
        stripRoot = false;
      };
      x86_64-darwin = fetchzip {
        url = "https://sdk.repebble.com/releases/${finalAttrs.version}/toolchain-mac-x86_64.tar.gz";
        hash = "sha256-Vjw++ijNQTNcHd4UYgi8iudn9qG6CG3qNP+uM8xIXZM=";
        stripRoot = false;
      };
      aarch64-darwin = fetchzip {
        url = "https://sdk.repebble.com/releases/${finalAttrs.version}/toolchain-mac-arm64.tar.gz";
        hash = "sha256-4KcQTJr9nrm97ZEgwbu5rxenWeizNMnI7C4tFbiQpaM=";
        stripRoot = false;
      };
    }).${stdenv.hostPlatform.system};

  nativeBuildInputs = lib.optional stdenv.hostPlatform.isLinux autoPatchelfHook;

  installPhase = ''
    mv toolchain-*/arm-none-eabi $out
  '';

  dontStrip = true;
})
