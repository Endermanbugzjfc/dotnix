# https://www.reddit.com/r/NixOS/comments/fsummx/how_to_list_all_installed_packages_on_nixos/
{ lib, config, inputs, ... }: {
  environment.etc."info/current-system-packages".text =
    let
    packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
    sortedUnique = builtins.sort builtins.lessThan (lib.lists.unique packages);
    formatted = builtins.concatStringsSep "\n" sortedUnique;
  in formatted;

  environment.etc."info/nixpkgs-path".text = builtins.toString inputs.nixpkgs;
}
