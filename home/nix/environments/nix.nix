{ pkgs, ... }: {
  home.packages = with pkgs; [
    nurl
  ];
}
