{ inputs, pkgs, lib, ... }: {
  home.packages = with pkgs; [
    brightnessctl
  ];

  imports = [
    inputs.nix-index-database.homeModules.nix-index
  ];
  programs.nix-index-database.comma.enable = true; # Run programs without installing.
}
