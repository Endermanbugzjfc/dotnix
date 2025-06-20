{ pkgs, lib, ... }: {
  home.packages = with pkgs; [
    nurl
  ];

  # Note: CLI not available when using as NixOS module:
  programs.home-manager.enable = lib.mkForce true;
}
