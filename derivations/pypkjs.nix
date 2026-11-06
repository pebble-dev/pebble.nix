{
  lib,
  stdenv,
  python3Packages,
  fetchFromGitHub,
  fetchPypi,
  autoPatchelfHook,
  makeWrapper,
  zlib,
}:

let
  quickjs-ng = python3Packages.buildPythonPackage rec {
    pname = "quickjs-ng";
    version = "0.17.0.2";

    src = fetchPypi {
      pname = "quickjs_ng";
      inherit version;
      hash = "sha256-Q9LkgnIghyGnquqOPwLUuTGPEu8gzE9UIbWdmkcHBu8=";
    };

    pyproject = true;
    build-system = [ python3Packages.setuptools ];

    pythonImportsCheck = [ "quickjs" ];
  };

  pygeoip = python3Packages.buildPythonPackage rec {
    pname = "pygeoip";
    version = "0.3.2";

    src = fetchFromGitHub {
      owner = "appliedsec";
      repo = "pygeoip";
      tag = "v${version}";
      hash = "sha256-D058c3o+2rTMQJpgwvFKd5Qwt2j7u4+GFpQHjO7lOVQ=";
    };

    postPatch = ''
      rm Makefile
    '';

    pyproject = true;
    build-system = [ python3Packages.setuptools ];
  };
in
python3Packages.buildPythonPackage rec {
  pname = "pypkjs";
  version = "3.0.3";

  src = fetchFromGitHub {
    owner = "coredevices";
    repo = "pypkjs";
    tag = "v${version}";
    fetchSubmodules = true;
    hash = "sha256-fV3agj5QGVD6ojkaSejr8vDP/yqxpP9isJRN3jIfS3M=";
  };

  nativeBuildInputs = [ makeWrapper ];

  propagatedBuildInputs = with python3Packages; [
    gevent
    gevent-websocket
    greenlet
    libpebble2
    netaddr
    peewee
    pygeoip
    pypng
    python-dateutil
    quickjs-ng
    requests
    sh
    six
    websocket-client
  ];

  pyproject = true;
  build-system = [ python3Packages.setuptools ];

  postFixup = ''
    wrapProgram $out/bin/pypkjs \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ stdenv.cc.cc.lib ]}
  '';

  meta = with lib; {
    homepage = "https://github.com/pebble/pypkjs";
    description = "Python implementation of PebbleKit JS";
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.darwin;
  };
}
