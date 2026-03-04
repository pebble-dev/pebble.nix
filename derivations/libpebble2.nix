{
  buildPythonPackage,
  fetchFromGitHub,
  pyserial,
  setuptools,
  six,
  websocket-client,
}:

buildPythonPackage rec {
  pname = "libpebble2";
  version = "0.0.31";
  src = fetchFromGitHub {
    owner = "pebble-dev";
    repo = "libpebble2";
    tag = "v${version}";
    hash = "sha256-4waUs0QeMI0dWL5Dk1HwL/5pK2uOfCFyJaK1MuRkuBw=";
  };

  propagatedBuildInputs = [
    pyserial
    six
    websocket-client
  ];

  pyproject = true;
  build-system = [ setuptools ];
}
