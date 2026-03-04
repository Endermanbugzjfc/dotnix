{ pkgs, ... }: {
  home.packages = with pkgs; [
    google-chrome

    parsec-bin
    moonlight-qt
  ];

  programs.nushell.environmentVariables.CSE = "z5667590@login0.unsw.edu.au"
}
