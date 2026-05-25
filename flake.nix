{
  description = "Tools for building Pebble apps on Nix systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-compat = {
      url = "https://git.lix.systems/lix-project/flake-compat/archive/main.tar.gz";
      flake = false;
    };

    commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      commit-hooks,
      nixpkgs,
      ...
    }:
    let
      forEachSystem =
        fn:
        nixpkgs.lib.genAttrs
          [
            "x86_64-linux"
            "x86_64-darwin"
            "aarch64-darwin"
          ]
          (
            system:
            fn system (
              import nixpkgs {
                inherit system;
                config = {
                  permittedInsecurePackages = [
                    "python-2.7.18.12"
                    "python-2.7.18.12-env"
                  ];
                };
                overlays = [ self.overlays.default ];
              }
            )
          );
    in
    rec {
      pebbleEnv = forEachSystem (_: pkgs: pkgs.callPackage ./buildTools/pebbleEnv.nix { });

      buildPebbleApp = forEachSystem (
        system: pkgs:
        import ./buildTools/buildPebbleApp.nix {
          inherit pkgs nixpkgs system;
          pebble-tool = packages.pebble-tool;
          python-libs = pkgs.callPackage ./derivations/pebble-tool/python-libs.nix { };
        }
      );

      packages = forEachSystem (
        _: pkgs: {
          inherit (pkgs)
            pdc-sequencer
            pdc_tool
            pebble-qemu
            pebble-tool
            pebble-toolchain-bin
            pypkjs
            pyv8
            ;
        }
      );

      devShell = forEachSystem (
        system: pkgs:
        pkgs.mkShell {
          name = "pebble.nix-devshell";
          packages = with pkgs; [
            nil
            nixfmt
          ];

          inherit (self.checks.${system}.pre-commit) shellHook;
        }
      );

      checks = forEachSystem (
        system: _: {
          pre-commit = commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixfmt.enable = true;
              nil.enable = true;
            };
          };
        }
      );

      overlays.default = import ./overlay.nix;

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
