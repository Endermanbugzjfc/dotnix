{ pkgs, ... }: {
  home.packages = with pkgs; [
    google-chrome
    moonlight-qt
  ];

  programs.nushell.environmentVariables.CSE = "z5667590@login0.cse.unsw.edu.au";
}
