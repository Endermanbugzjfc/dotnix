{ pkgs, lib, ... }: {
  home.packages = with pkgs; [
    nurl
  ];
}
