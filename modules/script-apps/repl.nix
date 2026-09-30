# A simple command to activate Nix REPL.

{
  perSystem = { pkgs, ... }: {
    packages.script-apps-repl = pkgs.writeShellScriptBin "repl" ''
      nix repl --expr 'import <nixpkgs> {}'
    '';
  };
}

