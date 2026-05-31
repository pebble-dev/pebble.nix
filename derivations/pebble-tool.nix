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
  version = "5.0.35";

  src = fetchFromGitHub {
    owner = "coredevices";
    repo = "pebble-tool";
    tag = "v${version}";
    hash = "sha256-quBDT7Sh14v7N47H1EVsvELT3Kb7Oo9CkKx/OfvOkFs=";
  };

  postPatch = ''
    substituteInPlace pebble_tool/sdk/__init__.py --replace \
      'tmp_link = "/var/tmp/pebble-sdk"' \
      'tmp_link = os.path.join(os.environ.get("TMPDIR", "/tmp"), "pebble-sdk")'
    substituteInPlace pebble_tool/util/__init__.py --replace \
      'dir = os.path.expanduser("~/.pebble-sdk")' \
      'dir = os.environ.get("PEBBLE_SDK", os.path.expanduser("~/.pebble-sdk"))'
  '';

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
