let
  system = builtins.currentSystem;

  lockFile = builtins.fromJSON (builtins.readFile ./flake.lock);
  flake-compat-node = lockFile.nodes.${lockFile.nodes.root.inputs.flake-compat};
  flake-compat = builtins.fetchTarball {
    inherit (flake-compat-node.locked) url;
    sha256 = flake-compat-node.locked.narHash;
  };

  flake =
    (import flake-compat {
      src = ./.;
    }).defaultNix;
in
{
  buildPebbleApp = flake.buildPebbleApp.${system};
  packages = flake.packages.${system};
  pebbleEnv = flake.pebbleEnv.${system};

  packagesAllArchs = flake.packages;
}
