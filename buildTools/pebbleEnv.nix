{
  mkShell,
  lib,
  coredevices,
  nodejs,
  pebble-qemu,
  pebble-tool,
  pebble-toolchain-bin,
}:

{
  devServerIP ? "",
  emulatorTarget ? "",
  cloudPebble ? false,
  nativeBuildInputs ? [ ],
  packages ? [ ],
  CFLAGS ? "",
  withCoreDevices ? false,
  ...
}@attrs:

let
  rest = builtins.removeAttrs attrs [
    "cloudPebble"
    "devServerIP"
    "emulatorTarget"
    "nativeBuildInputs"
    "name"
    "packages"
    "CFLAGS"
  ];

  pebbleToolPackage = if withCoreDevices then coredevices.pebble-tool else pebble-tool;
in
mkShell (
  {
    name = "pebble-env";
    packages =
      [
        nodejs
        pebble-qemu
        pebbleToolPackage
        pebble-toolchain-bin
      ]
      ++ packages
      ++ nativeBuildInputs;

    env = {
      inherit CFLAGS;
      PEBBLE_PHONE = devServerIP;
      PEBBLE_EMULATOR = emulatorTarget;
      PEBBLE_CLOUDPEBBLE = if cloudPebble then "1" else "";
      PEBBLE_EXTRA_PATH = lib.makeBinPath [
        pebble-qemu
        pebble-toolchain-bin
      ];
    };
  }
  // rest
)
