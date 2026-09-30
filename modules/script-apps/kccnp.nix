# A simple command to activate Nix stdenv.
# This is useful to peek what commands are available in the stdenv.

{
  perSystem = { pkgs, ... }: {
    packages.script-apps-kccnp = pkgs.writeShellApplication {
      name = "kccnp";
      text = ''
        nix-shell --pure --expr '(import <nixpkgs> {}).mkShellNoCC {}'
      '';
    };
  };
}

