{
  mkShellNoCC,
  lib,
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
in
mkShellNoCC (
  {
    name = "pebble-env";
    packages =
      lib.warnIf (attrs ? withCoreDevices)
        "Core Devices' pebble-tool is now the only supported version, and withCoreDevices no longer has any effect. It can be safely removed."
        (
          [
            nodejs
            pebble-qemu
            pebble-tool
            pebble-toolchain-bin
          ]
          ++ packages
          ++ nativeBuildInputs
        );

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
