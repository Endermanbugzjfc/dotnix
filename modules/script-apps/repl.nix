# A simple command to activate Nix REPL.

{
  perSystem = { pkgs, ... }: {
    packages.script-apps-repl = pkgs.writeShellApplication {
      name = "repl";
      text = ''
        nix repl --expr 'import <nixpkgs> {}'
      '';
    };
  };
}

