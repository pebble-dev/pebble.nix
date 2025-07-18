{
  description = "Tools for building Pebble apps on Nix systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    flake-compat.url = "github:edolstra/flake-compat";

    commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      commit-hooks,
      flake-utils,
      nixpkgs,
      ...
    }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ] (
      system:
      let
        config = {
          permittedInsecurePackages = [
            "python-2.7.18.8"
            "python-2.7.18.8-env"
          ];
        };
        pkgs = import nixpkgs {
          inherit system config;
          overlays = [ self.overlays.default ];
        };
      in
      rec {
        pebbleEnv = pkgs.callPackage ./buildTools/pebbleEnv.nix { };

        buildPebbleApp = import ./buildTools/buildPebbleApp.nix {
          inherit pkgs nixpkgs system;
          pebble-tool = packages.pebble-tool;
          python-libs = pkgs.callPackage ./derivations/pebble-tool/python-libs.nix { };

        };
        packages = {
          inherit (pkgs)
            arm-embedded-toolchain
            boost153
            coredevices
            pdc-sequencer
            pdc_tool
            pebble-qemu
            pebble-tool
            pebble-toolchain-bin
            pypkjs
            pyv8
            ;
        };

        devShell = pkgs.mkShell {
          name = "pebble.nix-devshell";
          packages = with pkgs; [
            nil
            nixfmt-rfc-style
          ];

          inherit (self.checks.${system}.pre-commit) shellHook;
        };

        checks.pre-commit = commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixfmt-rfc-style.enable = true;
            nil.enable = true;
          };
        };
      }
    )
    // {
      overlays.default = final: prev: {
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
      };

      templates = rec {
        basic = {
          path = ./templates/basic;
          description = "A simple pebble.nix project, with a development shell for building Pebble apps";
          welcomeText = ''
            # Next Steps
            - Check out the Pebble Developer docs: https://developer.rebble.io
            - See what else pebble.nix can do: https://github.com/pebble-dev/pebble.nix
            - Join us in the Rebble Discord server, and get help writing Pebble apps in #app-dev: https://discordapp.com/invite/aRUAYFN
          '';
        };

        default = basic;
      };
    };
}
