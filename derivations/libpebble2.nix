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
  version = "0.0.30";
  src = fetchFromGitHub {
    owner = "pebble-dev";
    repo = "libpebble2";
    tag = "v${version}";
    hash = "sha256-jzN3bMp7hCCFP6wQ4woXTgOmehczvn7cLqen9TlG7Dc=";
  };

  propagatedBuildInputs = [
    pyserial
    six
    websocket-client
  ];

  pyproject = true;
  build-system = [ setuptools ];
}
