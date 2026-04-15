{ config, inputs, pkgs, ... }: {
  lib = with pkgs; let
    flake-template-top = writeText "flake.nix.a" ''
      {
        inputs = {
          flake-utils.url = "github:numtide/flake-utils";
          nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
          nixche.url = "github:ezjfc/nixche";
        };

        outputs = inputs:
          inputs.flake-utils.lib.eachDefaultSystem (system:
            let
              pkgs = inputs.nixpkgs.legacyPackages.''${system};
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
    flake-lsp-os = writeText "flake.nix.c" ''
      {
        inputs = {
          flake-utils.url = "github:numtide/flake-utils";
          nixpkgs.url = ${inputs.nixpkgs};
          nixche.url = "github:ezjfc/nixche";
        };

        outputs = inputs:
          inputs.flake-utils.lib.eachDefaultSystem (system:
            let
              overlay = inputs.nixche.overlays.nvim-with-lsps;
              pkgs = inputs.nixpkgs.legacyPackages.''${system}.extend overlay;
            in {
              devShell = pkgs.mkShellNoCC {
                packages = with pkgs; [
                  (neovim.withLsps {

    '';
    flake-lsp-top = writeText "flake.nix.d" ''
      {
        inputs = {
          flake-utils.url = "github:numtide/flake-utils";
          nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
          nixche.url = "github:ezjfc/nixche";
        };

        outputs = inputs:
          inputs.flake-utils.lib.eachDefaultSystem (system:
            let
              overlay = inputs.nixche.overlays.nvim-with-lsps;
              pkgs = inputs.nixpkgs.legacyPackages.''${system}.extend overlay;
            in {
              devShell = pkgs.mkShellNoCC {
                packages = with pkgs; [
                  (neovim.withLsps {

    '';
    flake-lsp-middle = writeText "flake.nix.e" "            })\n";
    flake-lsp-bottom = writeText "flake.nix.f" ''
                ];
              };
            }
          );
      }
    '';
  in {
    inherit flake-template-top
            flake-template-bottom
            flake-lsp-os
            flake-lsp-top
            flake-lsp-middle
            flake-lsp-bottom;
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
    '';
  in ps;

  subcommands.flake = {};
  programs.nushell.configFile.text = let
    cmds = ''
      ${flake-init}
    '';
    # TODO: lsps and nixche
    flake-init = ''
      def "flake init" [
        --packages (-p): string = "",
        --dry,
      ] {
        mut expr = "";
        $expr += (cat ${config.lib.flake-template-top})
        $expr += $"            ($packages)"
        $expr += (cat ${config.lib.flake-template-bottom})
        echo $expr
        if ($dry) {
          print $expr
          return
        }

        if ("flake.nix" | path exists | not $in) {
          $expr | save flake.nix
          git add flake.nix
          print "Created and staged flake.nix"
        } else {
          panic "flake.nix already exists"
        }

        if (".envrc" | path exists | not $in) {
          print "use flake" | save .envrc
          git add .envrc

          print "Created and staged .envrc"
          direnv allow
        } # Not really cares if .envrc exists
      }
    '';
  in cmds;
}
