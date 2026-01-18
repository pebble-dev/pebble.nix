{
  lib,
  fetchFromGitHub,
  makeWrapper,
  coredevices,
  nodejs,
  python3Packages,
  zlib,
}:

let
  rpath = lib.makeLibraryPath [
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

    postPatch = ''
      rm Makefile
    '';

    pyproject = true;
    build-system = [ python3Packages.setuptools ];
  };

  libpebble2 = python3Packages.buildPythonPackage rec {
    pname = "libpebble2";
    version = "0.0.30";
    src = fetchFromGitHub {
      owner = "pebble-dev";
      repo = "libpebble2";
      tag = "v${version}";
      hash = "sha256-jzN3bMp7hCCFP6wQ4woXTgOmehczvn7cLqen9TlG7Dc=";
    };

    propagatedBuildInputs = with python3Packages; [
      pyserial
      six
      websocket-client
    ];

    pyproject = true;
    build-system = [ python3Packages.setuptools ];
  };
in
python3Packages.buildPythonPackage rec {
  pname = "pebble-tool";
  version = "5.0.21";

  src = fetchFromGitHub {
    owner = "coredevices";
    repo = "pebble-tool";
    tag = "v${version}";
    hash = "sha256-hF4G6NUXZtWG8qZ10pMd4QeIvqCjmxFcuH4a3xR1NrQ=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ nodejs ];

  propagatedBuildInputs = with python3Packages; [
    cobs
    coredevices.pypkjs
    colorama
    freetype-py
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
    websockify
    wheel
  ];

  pyproject = true;
  build-system = [ python3Packages.hatchling ];

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
