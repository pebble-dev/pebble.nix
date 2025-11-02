{
  stdenv,
  lib,
  fetchzip,
  autoPatchelfHook,

  expat,
  ncurses5,
  python2,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pebble-toolchain-bin";
  version = "4.5";

  src =
    (rec {
      x86_64-linux = fetchzip {
        url = "https://sdk.core.store/releases/${finalAttrs.version}/toolchain-linux.tar.gz";
        hash = "sha256-RDMrFzwjJpWGmB2LrXJIZugf5PzJ4KI9N32A5e1n4es=";
        stripRoot = false;
      };
      x86_64-darwin = fetchzip {
        url = "https://sdk.core.store/releases/${finalAttrs.version}/toolchain-mac.tar.gz";
        hash = "sha256-X49vcPSYt7fox5HBUhTwaob8y50mS7lgSfeqEW5imjY=";
        stripRoot = false;
      };
      aarch64-darwin = x86_64-darwin;
    }).${stdenv.hostPlatform.system};

  nativeBuildInputs = lib.optional stdenv.hostPlatform.isLinux autoPatchelfHook;
  buildInputs =
    [ python2 ]
    ++ (lib.optionals stdenv.hostPlatform.isLinux [
      expat
      ncurses5
      python2
      zlib
    ]);

  installPhase = ''
    mv toolchain-*/arm-none-eabi $out
  '';

  fixupPhase = lib.optionalString stdenv.hostPlatform.isDarwin ''
    # TODO: this doesn't work on apple silicon. figure out how to conjure an x86_64 python2 on there
    install_name_tool -change /System/Library/Frameworks/Python.framework/Versions/2.7/Python ${python2}/lib/libpython2.7.dylib $out/bin/arm-none-eabi-gdb
  '';
})
