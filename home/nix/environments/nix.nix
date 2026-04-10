{ config, inputs, pkgs, ... }: {
  lib = with pkgs; let
    flake-template-top = writeText "flake.nix.a" ''
      {
        inputs = {
          flake-utils.url = "github:numtide/flake-utils";
          nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        };

        outputs = inputs:
          inputs.flake-utils.lib.eachDefaultSystem (system:
            let
              pkgs = (import (inputs.nixpkgs) { inherit system; });
            in {
              devShell = pkgs.mkShellNoCC {
                packages = with pkgs; [
    '';
    flake-template-bottom = writeText "flake.nix.b" ''
                ];
              };
            }
          );
      }
    '';
  in {
    inherit flake-template-top flake-template-bottom;
  };


  home.packages = let
    ps = with pkgs; [
      nh
      nurl

      kccnp
      repl
      repl-update
      flake-init

      inputs.nix-update-input.packages.${pkgs.stdenv.hostPlatform.system}.default # Command: update-input.
    ];
    kccnp = pkgs.writeShellScriptBin "kccnp" ''
      nix-shell --pure --expr '(import <nixpkgs> {}).mkShellNoCC {}'
    '';
    repl = pkgs.writeShellScriptBin "repl" ''
      nix repl --expr 'import <nixpkgs> {}'
    '';
    repl-update = pkgs.writeShellScriptBin "repl-update" ''
      nix repl --expr 'import (fetchTarball
        "https://github.com/nixos/nixpkgs/tarball/nixpkgs-unstable"
      ) {}'
    '';
    flake-init = pkgs.writeShellScriptBin "flake-init" ''
      cat ${config.lib.flake-template-top} >> flake.nix
      echo "            $*" >> flake.nix
      cat ${config.lib.flake-template-bottom} >> flake.nix

      git add ./flake.nix
      echo "use flake" >> .envrc
      direnv allow
    '';
  in ps;
}
