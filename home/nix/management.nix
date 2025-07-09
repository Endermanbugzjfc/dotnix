{ inputs, pkgs, lib, ... }: {
  home.packages = with pkgs; [
    brightnessctl
    home-manager
  ];

  imports = [
    inputs.nix-index-database.hmModules.nix-index
  ];
  programs.nix-index-database.comma.enable = true; # Run programs without installing.

  # Note: CLI not available when using as NixOS module:
  programs.home-manager.enable = lib.mkForce true;
}
