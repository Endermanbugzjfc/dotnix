# This exists because certain packages, including all unfree ones are not
# supported by Comma. `,,man` plays the role of `,man` at this moment before
# the official implementation is complete (first mentioned in 2023).

{ config, lib, ... }: let
  inherit (lib) mkEnableOption mkDefault mkIf;
  cfg = config.features.nushell-comma-extended;
in {
  options.features.nushell-comma-extended = {
    enable = mkEnableOption "alternative nushell command of comma";
    man.enable = mkEnableOption "alias of `,pkgs --man`";
  };
  config.features.nushell-comma-extended = {
    enable = mkDefault true;
    man.enable = mkDefault true;
  };
  programs.nushell.extraConfig = mkIf cfg.enable ''
    def ,pkgs [ pkg: string, --bin (-b): string --man ] {
      mut bin = $bin | default $pkg
      if $man { $bin = $"man ($bin)" }
      $"(nix shell nixpkgs#($pkg) -c sh -c ($bin))"
    }
  '';
  programs.nushell.shellAliases.",,man" = mkIf cfg.man.enable ",pkgs --man";
}
