final: prev: {
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
