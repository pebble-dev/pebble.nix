{
  lib,
  fetchFromGitHub,
  makeWrapper,
  coredevices,
  freetype,
  nodejs,
  python3Packages,
  zlib,
}:

let
  rpath = lib.makeLibraryPath [
    freetype
    zlib
  ];

  sourcemap = python3Packages.buildPythonPackage rec {
    pname = "sourcemap";
    version = "0.2.1";

    src = fetchFromGitHub {
      owner = "mattrobenolt";
      repo = "python-sourcemap";
      tag = version;
      hash = "sha256-xVVBtwYPAsScYitINnKhj3XOgapXzQnXvmuF0B4Kuac=";
    };
  };

  libpebble2 = python3Packages.buildPythonPackage {
    pname = "libpebble2";
    version = "0.0.28";
    src = fetchFromGitHub {
      owner = "pebble-dev";
      repo = "libpebble2";
      rev = "575fe2cfae39e1a1c61937d4e90628a3d5790a4d";
      hash = "sha256-bQNeJoiQhg/twMcYpgvBOG/mutm3Fuf9iwF0y5UgWs0=";
    };

    propagatedBuildInputs = with python3Packages; [
      pyserial
      six
      websocket_client
    ];
  };
in
python3Packages.buildPythonPackage {
  pname = "pebble-tool";
  version = "5.0.2";

  src = fetchFromGitHub {
    owner = "coredevices";
    repo = "pebble-tool";
    rev = "d99857c7a30695d0fd710a25e2bb4689c57b58ef";
    hash = "sha256-Ouhx7oam/uDdShZAPJjkMGm7SlCDSglWqDYzJ584aPY=";
  };

  patches = [
    # We have our own versions of the compiler toolchain and pebble-qemu, and we want to use those. SDK 4.4 ships
    # precompiled versions of these, which won't work on NixOS.
    ./no-sdk-binaries.patch
  ];

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ nodejs ];

  propagatedBuildInputs = with python3Packages; [
    coredevices.pypkjs
    colorama
    httplib2
    libpebble2
    oauth2client
    packaging
    progressbar2
    pyasn1
    pyasn1-modules
    pypng
    pyqrcode
    pyserial
    requests
    rsa
    six
    sourcemap
    websocket-client
    wheel

    freetype
  ];

  postFixup = ''
    wrapProgram $out/bin/pebble \
      --prefix PATH : ${lib.makeBinPath [ nodejs ]} \
      --prefix LD_LIBRARY_PATH : ${rpath} \
      --prefix DYLD_LIBRARY_PATH : ${rpath}
  '';

  meta = with lib; {
    homepage = "https://developer.rebble.io/developer.pebble.com/index.html";
    description = "Tool for interacting with the Pebble SDK";
    license = licenses.mit;
    mainProgram = "pebble";
    platforms = platforms.linux ++ platforms.darwin;
  };
}
