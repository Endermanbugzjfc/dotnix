# NvChad

{ pkgs, ... }: {
  home.packages = with pkgs; [
    claude-code
  ];

  # config.nixpkgs.overlays = [ inputs.nixche.overlays.neovim-with-lsps ];
  # config.lib.mkLspShell = opt: lsp: pkgs.mkShellNoCC {
  #   packages = [
  #     (pkgs.neovim.withLsps lsp)
  #   ] ++ (opt.packages or []);
  # };
}
