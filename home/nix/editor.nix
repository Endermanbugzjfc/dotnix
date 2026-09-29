# NvChad

{ pkgs, inputs, ... }: {
  home.packages = (with pkgs; [
    claude-code
    opencode
  ]) ++ [
    inputs.codex-cli.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # config.nixpkgs.overlays = [ inputs.nixche.overlays.neovim-with-lsps ];
  # config.lib.mkLspShell = opt: lsp: pkgs.mkShellNoCC {
  #   packages = [
  #     (pkgs.neovim.withLsps lsp)
  #   ] ++ (opt.packages or []);
  # };
}
