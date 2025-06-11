# NvChad

{ inputs, ... }: {
  home.file.".config/nvim" = {
    source = "${inputs.nvim-config}";
    recursive = true;
  };

  # https://www.reddit.com/r/NixOS/comments/1e29wld/using_mason_lazy_in_nixos/
  home.sessionPath = [
    "$HOME/.local/share/nvim/mason/bin" # nvim-lspconfig
  ];
}
