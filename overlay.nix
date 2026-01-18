final: prev: {
  python3 =
    let
      packageOverrides = final': prev': {
        libpebble2 = final'.callPackage ./derivations/libpebble2.nix { };

        rsa = prev'.rsa.overrideAttrs {
          version = "4.9.1";
          src = final.fetchFromGitHub {
            owner = "sybrenstuvel";
            repo = "python-rsa";
            rev = "42b0e14ffbeeb9d99d1037e6440a2cc61780e4ea";
            hash = "sha256-iZ+BehQkdZJ1n9mz1SzK8a7NwQGSxbOz48OZ4qrbqOE=";
          };
        };
      };
    in
    (prev.python3.override {
      inherit packageOverrides;
      self = final.python3;
    });
  python3Packages = final.python3.pkgs;

  arm-embedded-toolchain = final.callPackage ./derivations/arm-embedded-toolchain { };
  boost153 = final.callPackage ./derivations/boost153 { };
  pdc-sequencer = final.callPackage ./derivations/pdc-sequencer.nix { };
  pdc_tool = final.callPackage ./derivations/pdc_tool.nix { };
  pebble-qemu = final.callPackage ./derivations/pebble-qemu.nix { };
  pebble-tool = final.callPackage ./derivations/pebble-tool { };
  pebble-toolchain-bin = final.callPackage ./derivations/pebble-toolchain-bin.nix { };
  pypkjs = final.pebble-tool.passthru.pythonLibs.pypkjs;
  pyv8 = final.callPackage ./derivations/pyv8 { };

  coredevices = {
    pypkjs = final.callPackage ./derivations/coredevices/pypkjs.nix { };
    pebble-tool = final.callPackage ./derivations/coredevices/pebble-tool.nix { };
  };
}
