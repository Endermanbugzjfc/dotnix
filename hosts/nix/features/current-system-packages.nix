# https://www.reddit.com/r/NixOS/comments/fsummx/how_to_list_all_installed_packages_on_nixos/

{ config, lib, ... }: let
  inherit (lib) mkEnableOption mkOption mkDefault types;
  cfg = config.features.current-system-packages;
in {
  options.features.current-system-packages = {
    enable = mkEnableOption "file that lists all installed packages";
    file = mkOption {
      type = with types; str;
      description = "Name of the file which will be placed in /etc";
      default = "current-system-packages";
    };
  };
  config.features.current-system-packages.enable = mkDefault true;
  environment.etc.${cfg.file} = {
    enable = cfg.enable;
    text = let
      packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
      sortedUnique = builtins.sort builtins.lessThan (lib.lists.unique packages);
      formatted = builtins.concatStringsSep "\n" sortedUnique;
    in formatted;
  };
}
