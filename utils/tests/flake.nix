{
  description = ''
    https://github.com/Endermanbugzjfc/dotnix | Unlicense

    Unit tests for overlay utils, based on:
    https://nix-community.github.io/nix-unit/examples/flake-parts.html
    Evaluation warnings will not display in the tests but instead be embedded
    to a `_warn` attribute inside the returned value to work with the tests.

    NOTE: It is NOT necessary to use or understand this flake before opting in
    utilities from the parent directory.
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-systems.url = "github:nix-systems/default";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nix-unit = {
      url = "github:nix-community/nix-unit";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
    utilities.url = ../.;
  };

  outputs = {
    self,
    nixpkgs,
    nix-systems,
    flake-parts,
    nix-unit,
    utilities,
  } @ inputs: flake-parts.lib.mkFlake { inherit inputs; } {

    imports = [
      nix-unit.modules.flake.default
    ];
    systems = import nix-systems;
    perSystem = { lib, ... }: {
      nix-unit.inputs = {
        # NOTE: a `nixpkgs-lib` follows rule is currently required
        inherit nixpkgs nix-systems flake-parts nix-unit utilities;
      };

      nix-unit.tests = let
        mkTest = subject: import "${self}/${subject}-tests.nix" {
          lib' = with lib; extend(composeManyExtensions [
            (import "${utilities}/${subject}.nix")
            # This hijacks warn functions in `lib`:
            (final: prev: let
              warnIf = cond: msg: value: if cond then (
                if (builtins.isAttrs value)
                  then value // { "_warn" = msg; }
                  else value ++ [ msg ]
              ) else value;
            in {
              inherit warnIf;
            })
          ]);
        };
      in lib.genAttrs [
        "warn-dupe" "mk-list" "enable-multi"
      ] mkTest;
    };
  };
}
