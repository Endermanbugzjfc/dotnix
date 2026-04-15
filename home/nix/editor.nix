# NvChad

{ config, lib, pkgs, inputs, ... }: {
  options.mobile-shells = with lib; let
    opts = { name, ... }: {
      options = {
        command = mkOption {
          type = with types; str;
          default = name;
        };
        packages = mkOption {
          type = with types; listOf package;
          default = [];
        };

        lsps = mkOption {
          type = with types; attrsOf package;
          default = {};
        };
      };
    };
  in mkOption {
    type = with types; attrsOf (submodule opts);
    default = [];
  };

  config.nixpkgs.overlays = [ inputs.nixche.overlays.neovim-with-lsps ];
  config.lib.mkLspShell = opt: lsp: pkgs.mkShellNoCC {
    packages = [
      (pkgs.neovim.withLsps lsp)
    ] ++ (opt.packages or []);
  };
  config.subcommands.shell = {};
  config.programs.nushell.configFile.text = let
    cfg = config.mobile-shells;
    cmds = lib.mapAttrsToList (name: opts: let
      shell = pkgs.mkShellNoCC {
        packages = opts.packages ++ [
          (pkgs.neovim.withLsps opts.lsps)
        ];
      };
    in ''
      def "shell ${opts.command}" [] {
        nix-shell --impure ${shell.drvPath}
      }
    '') cfg;
  in lib.concatStringsSep "\n" cmds;
}
