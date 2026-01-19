{
  stdenv,
  lib,
  fetchFromGitHub,
  autoconf,
  automake,
  bison,
  darwin,
  flex,
  glib,
  libtool,
  libx11,
  perl,
  pixman,
  pkg-config,
  python2,
  SDL2,
  zlib,
}:

let
  darwinDeps = lib.optionals stdenv.isDarwin (
    with darwin.apple_sdk.frameworks;
    with darwin.stubs;
    [
      CoreAudio
      IOKit
      rez
      setfile
    ]
  );
in
stdenv.mkDerivation {
  name = "pebble-qemu";
  version = "2.5.0-pebble8";

  src = fetchFromGitHub {
    owner = "coredevices";
    repo = "qemu";
    rev = "a0da0db291d92d491b4883cec01ba8f088ef5b3b";
    hash = "sha256-DVep6uwHw/1oyzHLYmWQPu6taD2bRkmcq/pA6PsY2Fc=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    autoconf
    automake
    bison
    flex
    libtool
    perl
    pkg-config
    python2
  ];

  buildInputs = [
    glib
    libx11
    pixman
    SDL2
    zlib
  ]
  ++ darwinDeps;

  configureFlags = [
    "--with-coroutine=gthread"
    "--disable-werror"
    "--disable-mouse"
    "--disable-vnc"
    "--disable-cocoa"
    "--enable-debug"
    "--enable-sdl"
    "--with-sdlabi=2.0"
    "--target-list=arm-softmmu"
    "--extra-cflags=-DSTM32_UART_NO_BAUD_DELAY"
    "--extra-ldflags=-g"
  ];

  postInstall = ''
    mv $out/bin/qemu-system-arm $out/bin/qemu-pebble
  '';

  meta = with lib; {
    homepage = "https://github.com/pebble/qemu";
    description = "Fork of QEMU with support for Pebble devices";
    license = licenses.gpl2Plus;
    mainProgram = "qemu-pebble";
    platforms = platforms.linux ++ platforms.darwin;
  };
}
