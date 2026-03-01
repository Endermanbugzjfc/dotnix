{ inputs, pkgs, ... }: {
  home.packages = with pkgs; [
    nurl
    (writeShellScriptBin "kccnp" ''
      nix-shell --pure --expr '(import <nixpkgs> {}).mkShellNoCC {}'
    '')
    (writeShellScriptBin "repl" ''
      nix repl --expr 'import <nixpkgs> {}'
    '')
    (writeShellScriptBin "repl-update" ''
      nix repl --expr 'import (fetchTarball
        "https://github.com/nixos/nixpkgs/tarball/nixpkgs-unstable"
      ) {}'
    '')

    inputs.nix-update-input.packages.${pkgs.stdenv.hostPlatform.system}.default # Command: update-input.
  ];
}
