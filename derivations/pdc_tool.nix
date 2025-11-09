{
  stdenv,
  lib,
  fetchzip,
}:

let
  version = "0.3.4";

  binaryArchive = {
    x86_64-linux = fetchzip {
      url = "https://github.com/HBehrens/pdc_tool/releases/download/v${version}/pdc_tool_linux_x86_64-unknown-linux-musl.zip";
      hash = "sha256-AChRPjcj2WdHMjYzBQwZ8Fe8LuryavVHqS7SvqNwtDg=";
    };
    x86_64-darwin = fetchzip {
      url = "https://github.com/HBehrens/pdc_tool/releases/download/v${version}/pdc_tool_macos_x86_64-apple-darwin.zip";
      hash = "sha256-lcYa9RoQpsXXwr9S3yvOe/AyCIgOHXdHpf80LRA7vPo=";
    };
    aarch64-darwin = fetchzip {
      url = "https://github.com/HBehrens/pdc_tool/releases/download/v${version}/pdc_tool_macos_aarch64-apple-darwin.zip";
      hash = "sha256-4dHR4VP9twR0PyXMAICOOU8Lcu6Q/y4dWQIXe54YcYk=";
    };
  };
in
stdenv.mkDerivation {
  pname = "pdc_tool";
  inherit version;

  src = binaryArchive.${stdenv.hostPlatform.system};

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 pdc_tool $out/bin
  '';

  meta = {
    description = "Command-line interface for working with Pebble Draw Command (PDC) files";
    homepage = "https://github.com/HBehrens/pdc_tool";
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
      "x86_64-linux"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
