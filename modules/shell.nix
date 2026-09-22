{ inputs, ... }: {
  systems = [
    "x86_64-linux"
  ];
  perSystem = { system, pkgs, ... }: let
    nixche = inputs.nixche.packages.${system};
    inherit (nixche.write-alias-script) writeAliasScriptBin;
    inherit (nixche.write-lua-script) writeLuaScriptShare;
  in {
    devShells.default = pkgs.mkShellNoCC {
      packages = let
        nvim = writeAliasScriptBin "nvim" ''
          nvim -c "source ${nvim-config}/share/nvim-config.lua"
        '';
        nvim-config = writeLuaScriptShare {
          name = "nvim-config";
          buildInputs = builtins.attrNames LSPS;
          inherit LSPS;
          text = ''
            local env = ...
            for name, path in pairs(env.LSPS) do
              vim.lsp.enable(name)
            end
          '';
        };
        LSPS = {
          nil_ls = "nil";
          # See all names: `:h lspconfig-all`.
        };
      in [
        nvim-config
        nvim
      ];
    };
  };
}
