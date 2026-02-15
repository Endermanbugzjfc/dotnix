{
  programs.nh.enable = true;
  programs.ripgrep.enable = true;
  programs.ripgrep-all.enable = true;

  programs.nushell.aliases = {
    # Nix Read–Eval–Print Loop is like a Nix Playground thing:
    repl = "nix repl --expr 'import <nixpkgs> {}'";
    repl-update = ''
      nix repl --expr 'import (fetchTarball
        "https://github.com/nixos/nixpkgs/tarball/nixpkgs-unstable"
      ) {}'
    '';
    # Creates a Nix shell with built-in CLIs only:
    kccnp = ''
      nix-shell --pure --expr '(import <nixpkgs> {}).mkShellNoCC {
        shellHook = "echo 北角蘇浙公學 整齊嚴肅 This place has almost nothing useful";
      }'
    '';
  };
}
