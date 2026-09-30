# Dev environment of the repository you are currently looking at.

{ inputs, self, ... }: {
  perSystem = { pkgs, self', system, ... }: let
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
      ] ++ (with pkgs; [
        entr
      ]);

      __useStructuredAttrs = true;
      profilesPaths = self.lib.maidProfilesRelativePaths;
      shellHook = ''
        export INIT_WD=$(pwd)
        for profile in "''${profilesPaths[@]}"; do
          ls "$INIT_WD/$profile" #| entr -r echo "TODO: some stuff" &
        done

        on_exit() {
          echo "Exiting"
        }
        #
        trap on_exit EXIT
      '';
    };
  };
}
