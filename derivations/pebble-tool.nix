{
  lib,
  fetchFromGitHub,
  makeWrapper,
  nodejs,
  python3Packages,
  pypkjs,
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
in
python3Packages.buildPythonPackage rec {
  pname = "pebble-tool";
  version = "5.0.28";

  src = fetchFromGitHub {
    owner = "coredevices";
    repo = "pebble-tool";
    tag = "v${version}";
    hash = "sha256-zmtMmig7re1CB6WaXsFwPYMzB1UmNTx2uqgnpPg9mIg=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ nodejs ];

  propagatedBuildInputs = with python3Packages; [
    cobs
    colorama
    freetype-py
    google-auth-oauthlib
    google-auth
    httplib2
    libpebble2
    oauth2client
    packaging
    pillow
    progressbar2
    pyasn1
    pyasn1-modules
    pypkjs
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
