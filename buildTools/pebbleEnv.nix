{
  mkShell,
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
mkShell (
  {
    name = "pebble-env";
    packages =
      [
        nodejs
        pebble-qemu
        pebble-tool
        pebble-toolchain-bin
      ]
      ++ packages
      ++ nativeBuildInputs;

    env = {
      inherit CFLAGS;
      PEBBLE_PHONE = devServerIP;
      PEBBLE_EMULATOR = emulatorTarget;
      PEBBLE_CLOUDPEBBLE = if cloudPebble then "1" else "";
    };
  }
  // rest
)
