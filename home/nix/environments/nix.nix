{ pkgs, ... }: {
  home.packages = with pkgs; [
    nurl
    (writeShellScriptBin "kccnp" ''
      nix-shell --pure --expr '(import <nixpkgs> {}).mkShellNoCC {}'
    '')
  ];
}
