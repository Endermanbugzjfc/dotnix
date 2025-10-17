{ pkgs, ... }: {
  home.packages = with pkgs; [
    google-chrome

    parsec-bin
    moonlight-qt
  ];
}
