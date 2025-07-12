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
  stpyv8 = python3Packages.buildPythonPackage rec {
    pname = "stpyv8";
    version = "13.1.201.22";

    src =
      let
        pyShortVersion = "cp" + builtins.replaceStrings [ "." ] [ "" ] python3Packages.python.pythonVersion;
      in
      fetchPypi {
        inherit pname version;
        format = "wheel";
        dist = pyShortVersion;
        python = pyShortVersion;
        abi = pyShortVersion;
        platform =
          ({
            x86_64-linux = "manylinux_2_31_x86_64";
            x86_64-darwin = "macosx_13_0_x86_64";
            aarch64-darwin = "macosx_14_0_arm64";
          }).${stdenv.hostPlatform.system};
        hash =
          ({
            x86_64-linux = "sha256-wkqkIVxk231n/GxCwNdzHKvPMAWWv5yCaudPQm/jt3E=";
            x86_64-darwin = "sha256-/CuVa/ryNTHEkIRe232A/JmP6K7hx88TNzF9rgEWkwc=";
            aarch64-darwin = "sha256-bcQLZWzqf+VB9r262DtrTtUeXq2YW1TBOTGacxJTpV4=";
          }).${stdenv.hostPlatform.system};
      };

    pyproject = false;

    nativeBuildInputs = [
      python3Packages.pypaInstallHook
      python3Packages.wheelUnpackHook
    ] ++ (lib.optional stdenv.hostPlatform.isLinux autoPatchelfHook);

    buildInputs = [ zlib ];
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
  };
in
python3Packages.buildPythonPackage {
  pname = "pypkjs";
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "coredevices";
    repo = "pypkjs";
    rev = "9561f7ba3be73e2546b1cfdf6dcfbb416a7f64ca";
    hash = "sha256-/ZRwKXzQ5tHrViyfrEsI/sOQepCND7/Fr6AEHMUhuws=";
  };

  nativeBuildInputs = [ makeWrapper ];

  propagatedBuildInputs = with python3Packages; [
    gevent
    gevent-websocket
    greenlet
    netaddr
    peewee
    pygeoip
    pypng
    stpyv8
    dateutil
    requests
    sh
    six
    websocket_client
  ];

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
