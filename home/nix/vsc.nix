# Git, GitHub, Sublime Merge...

{ pkgs, ... }: {
  home.packages = with pkgs; [
    sublime-merge
  ];

  programs.gh.enable = true;
}
