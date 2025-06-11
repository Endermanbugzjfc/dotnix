# Keybase

{ pkgs, ... }: {
  home.packages = with pkgs; [
    keybase-gui
  ];
}
