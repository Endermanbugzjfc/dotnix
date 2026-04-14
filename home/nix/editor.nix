# NvChad

{ inputs, pkgs, ... }: {
  # https://www.reddit.com/r/NixOS/comments/1e29wld/using_mason_lazy_in_nixos/
  # home.sessionPath = [
  #   "$HOME/.local/share/nvim/mason/bin" # nvim-lspconfig
  # ];

  nixpkgs.overlays = [ inputs.nixche.overlays.neovim-with-lsps ];
  lib.mkLspShell = opt: lsp: pkgs.mkShellNoCC {
    packages = [
      (pkgs.neovim.withLsps lsp)
    ] ++ (opt.packages or []);
  };
}
