# Home lies packages and programs that require per-user (~/.config)
# configurations or login. As well as some packages that are too specific
# (see media.nix and word-processing.)

{ pkgs, lib, ... }: {
  imports = [
    ../common

    ./environments
    ./games

    ./vsc.nix
    ./media.nix
    ./editor.nix
    ./desktop.nix
    ./security.nix
    ./terminal.nix
    ./word-processing.nix
    ./information.nix
    ./social.nix
    ./internet.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  }; # TODO: make common

  home = {
    username = "rickastley";
    homeDirectory = "/home/rickastley";
    stateVersion = "25.05";

    # packages = with pkgs; [
#       # wl-clip-persistent
#       neofetch
#
#         google-chrome
#
#         gcc
#         cargo
# # https://nixos.wiki/wiki/Python
    # ];
  };
}
