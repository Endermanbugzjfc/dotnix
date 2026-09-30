# A simple command to activate Nix stdenv.
# This is useful to peek what commands are available in the stdenv.

{
  perSystem = { pkgs, ... }: {
    packages.script-apps-kccnp = pkgs.writeShellScriptBin "kccnp" ''
      nix-shell --pure --expr '(import <nixpkgs> {}).mkShellNoCC {}'
    '';
  };
}

